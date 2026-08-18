FROM alpine:latest

RUN apk add --no-cache wget unzip ca-certificates

WORKDIR /app

# PocketBase v0.39.10 (exists)
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_linux_amd64.zip && \
    unzip pocketbase_0.39.10_linux_amd64.zip && \
    rm pocketbase_0.39.10_linux_amd64.zip && \
    chmod +x pocketbase

# Litestream v0.5.14 (confirmed to exist)
RUN wget https://github.com/benbjohnson/litestream/releases/download/v0.5.14/litestream-linux-amd64.tar.gz && \
    tar -xzf litestream-linux-amd64.tar.gz && \
    rm litestream-linux-amd64.tar.gz && \
    chmod +x litestream

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
