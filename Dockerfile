# Stage 1: Get Litestream binary from official image
FROM litestream/litestream:latest as litestream

# Stage 2: Final image with PocketBase
FROM alpine:latest

RUN apk add --no-cache wget unzip ca-certificates

WORKDIR /app

# Copy Litestream binary from stage 1
COPY --from=litestream /usr/local/bin/litestream /app/litestream

# PocketBase v0.39.10
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_linux_amd64.zip && \
    unzip pocketbase_0.39.10_linux_amd64.zip && \
    rm pocketbase_0.39.10_linux_amd64.zip && \
    chmod +x pocketbase

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
