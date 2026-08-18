FROM alpine:latest

# Install dependencies (including curl and jq for API calls)
RUN apk add --no-cache wget unzip ca-certificates curl jq

WORKDIR /app

# PocketBase v0.39.10 (fixed version)
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_linux_amd64.zip && \
    unzip pocketbase_0.39.10_linux_amd64.zip && \
    rm pocketbase_0.39.10_linux_amd64.zip && \
    chmod +x pocketbase

# Litestream – get the latest version URL from GitHub API
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/benbjohnson/litestream/releases/latest | jq -r .tag_name) && \
    echo "Latest Litestream version: $LATEST_VERSION" && \
    wget https://github.com/benbjohnson/litestream/releases/download/${LATEST_VERSION}/litestream-linux-amd64.tar.gz && \
    tar -xzf litestream-linux-amd64.tar.gz && \
    rm litestream-linux-amd64.tar.gz && \
    chmod +x litestream

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
