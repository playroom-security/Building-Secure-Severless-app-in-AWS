"""
Lambda handler — secure serverless API backend.

Routes are dispatched based on the HTTP method and path from the API Gateway
v2 (HTTP API) payload format 2.0 event. The Cognito JWT authorizer injects
identity claims into requestContext.authorizer.jwt.claims.

Environment variables expected:
  TABLE_NAME   — DynamoDB table name
  ENVIRONMENT  — Deployment environment label (dev / prod)
  LOG_LEVEL    — Python logging level (DEBUG / INFO / WARNING / ERROR)
"""

import json
import logging
import os
import uuid
from datetime import datetime, timezone

import boto3
from boto3.dynamodb.conditions import Key

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger(__name__)

TABLE_NAME = os.environ["TABLE_NAME"]

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "X-Content-Type-Options": "nosniff",
        },
        "body": json.dumps(body),
    }


def get_caller_sub(event: dict) -> str:
    """Extract the Cognito 'sub' (user ID) from authorizer claims."""
    try:
        return event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]
    except (KeyError, TypeError):
        return "unknown"


# ---------------------------------------------------------------------------
# Route handlers
# ---------------------------------------------------------------------------


def get_items(event: dict) -> dict:
    caller_sub = get_caller_sub(event)
    logger.info("GET /items caller=%s", caller_sub)

    result = table.query(KeyConditionExpression=Key("PK").eq(f"USER#{caller_sub}"))
    return response(200, {"items": result.get("Items", [])})


def post_items(event: dict) -> dict:
    caller_sub = get_caller_sub(event)
    logger.info("POST /items caller=%s", caller_sub)

    body = json.loads(event.get("body") or "{}")
    item_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()

    item = {
        "PK": f"USER#{caller_sub}",
        "SK": f"ITEM#{item_id}",
        "itemId": item_id,
        "createdAt": now,
        **{k: v for k, v in body.items() if k not in ("PK", "SK")},
    }

    table.put_item(Item=item)
    return response(201, {"itemId": item_id, "createdAt": now})


def get_item(event: dict) -> dict:
    caller_sub = get_caller_sub(event)
    item_id = event.get("pathParameters", {}).get("id", "")
    logger.info("GET /items/%s caller=%s", item_id, caller_sub)

    result = table.get_item(Key={"PK": f"USER#{caller_sub}", "SK": f"ITEM#{item_id}"})
    item = result.get("Item")
    if not item:
        return response(404, {"message": "Item not found"})
    return response(200, item)


def delete_item(event: dict) -> dict:
    caller_sub = get_caller_sub(event)
    item_id = event.get("pathParameters", {}).get("id", "")
    logger.info("DELETE /items/%s caller=%s", item_id, caller_sub)

    table.delete_item(Key={"PK": f"USER#{caller_sub}", "SK": f"ITEM#{item_id}"})
    return response(204, {})


# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------

ROUTES = {
    ("GET", "/items"): get_items,
    ("POST", "/items"): post_items,
    ("GET", "/items/{id}"): get_item,
    ("DELETE", "/items/{id}"): delete_item,
}


def handler(event: dict, context) -> dict:
    method = event.get("requestContext", {}).get("http", {}).get("method", "")
    path = event.get("requestContext", {}).get("http", {}).get("path", "")

    # Normalise parameterised paths (e.g. /items/abc123 -> /items/{id})
    normalised_path = path
    path_parts = path.split("/")
    if len(path_parts) == 3 and path_parts[1] == "items" and path_parts[2]:
        normalised_path = "/items/{id}"

    route_fn = ROUTES.get((method, normalised_path))
    if route_fn is None:
        return response(404, {"message": f"Route not found: {method} {path}"})

    try:
        return route_fn(event)
    except Exception as exc:  # noqa: BLE001
        logger.exception("Unhandled error in route %s %s", method, path)
        return response(500, {"message": "Internal server error"})
