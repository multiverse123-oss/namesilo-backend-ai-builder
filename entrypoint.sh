#!/bin/sh
set -e

PB_DATA_DIR="/app/pb_data"
DB_PATH="$PB_DATA_DIR/data.db"
LITESTREAM_CONFIG="/app/litestream.yml"

# Use PORT from environment, default to 8080 if not set
PORT=${PORT:-8080}

# Set defaults for IDrive variables if not provided
IDRIVE_REGION=${IDRIVE_REGION:-us-midwest-1}
IDRIVE_ENDPOINT=${IDRIVE_ENDPOINT:-s3.us-midwest-1.idrivee2.com}
IDRIVE_BUCKET=${IDRIVE_BUCKET:-namesilo-backend}
IDRIVE_ACCESS_KEY=${IDRIVE_ACCESS_KEY:-}
IDRIVE_SECRET_KEY=${IDRIVE_SECRET_KEY:-}

# Required vars (must be set)
if [ -z "$IDRIVE_ACCESS_KEY" ] || [ -z "$IDRIVE_SECRET_KEY" ]; then
    echo "ERROR: IDRIVE_ACCESS_KEY and IDRIVE_SECRET_KEY must be set."
    exit 1
fi

mkdir -p "$PB_DATA_DIR"

cat > "$LITESTREAM_CONFIG" << EOC
dbs:
  - path: $DB_PATH
    replicas:
      - type: s3
        bucket: $IDRIVE_BUCKET
        endpoint: $IDRIVE_ENDPOINT
        path: pocketbase.db
        access-key-id: $IDRIVE_ACCESS_KEY
        secret-access-key: $IDRIVE_SECRET_KEY
        region: $IDRIVE_REGION
        skip-verify: false
EOC

/app/litestream restore -config "$LITESTREAM_CONFIG" "$DB_PATH" || echo "No existing backup to restore."

/app/litestream replicate -config "$LITESTREAM_CONFIG" &

/app/pocketbase serve --http=0.0.0.0:$PORT
