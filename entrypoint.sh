#!/bin/sh
set -e

PB_DATA_DIR="/app/pb_data"
DB_PATH="$PB_DATA_DIR/data.db"
LITESTREAM_CONFIG="/app/litestream.yml"

# Check required environment variables
for VAR in IDRIVE_ACCESS_KEY IDRIVE_SECRET_KEY IDRIVE_BUCKET IDRIVE_ENDPOINT IDRIVE_REGION; do
    if [ -z "$(eval echo \$$VAR)" ]; then
        echo "ERROR: $VAR is not set. Exiting."
        exit 1
    fi
done

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

/app/pocketbase serve --http=0.0.0.0:8080
