#!/bin/bash
set -e

BASE_URL="https://namesilo-backend-ai-builder.onrender.com"
ADMIN_EMAIL="admin@namesilo.com"
ADMIN_PASSWORD="Admin123456"

# Get admin token
TOKEN=$(curl -s -X POST "$BASE_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" \
  | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get admin token."
  exit 1
fi

echo "✅ Admin token obtained"

# Create projects collection
echo "📦 Creating projects collection..."
PROJECTS_RESPONSE=$(curl -s -X POST "$BASE_URL/api/collections" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "projects",
    "type": "base",
    "schema": [
      {"name": "name", "type": "text", "required": true},
      {"name": "prompt", "type": "text", "required": true},
      {"name": "files", "type": "json"},
      {"name": "user", "type": "relation", "required": true, "options": {"collectionId": "_pb_users_auth_", "maxSelect": 1}},
      {"name": "lastUpdated", "type": "date"}
    ],
    "listRule": "user = @request.auth.id",
    "viewRule": "user = @request.auth.id",
    "createRule": "@request.auth.id != \"\"",
    "updateRule": "user = @request.auth.id",
    "deleteRule": "user = @request.auth.id"
  }')
PROJECTS_ID=$(echo "$PROJECTS_RESPONSE" | jq -r '.id')
echo "✅ Projects collection created (ID: $PROJECTS_ID)"

# Create chat_messages collection
echo "📦 Creating chat_messages collection..."
curl -s -X POST "$BASE_URL/api/collections" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "chat_messages",
    "type": "base",
    "schema": [
      {"name": "project", "type": "relation", "required": true, "options": {"collectionId": "'"$PROJECTS_ID"'", "maxSelect": 1}},
      {"name": "role", "type": "select", "required": true, "options": {"values": ["user", "assistant"]}},
      {"name": "content", "type": "text", "required": true},
      {"name": "timestamp", "type": "date", "required": true}
    ],
    "listRule": "project.user = @request.auth.id",
    "viewRule": "project.user = @request.auth.id",
    "createRule": "@request.auth.id != \"\"",
    "updateRule": "project.user = @request.auth.id",
    "deleteRule": "project.user = @request.auth.id"
  }'
echo "✅ Chat messages collection created"
echo "🎉 All collections and rules are set up!"
