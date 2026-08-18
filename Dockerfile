FROM alpine:latest

RUN apk add --no-cache wget unzip ca-certificates

WORKDIR /app

# PocketBase v0.39.10 (exists)
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_linux_amd64.zip && \
    unzip pocketbase_0.39.10_linux_amd64.zip && \
    rm pocketbase_0.39.10_linux_amd64.zip && \
    chmod +x pocketbase

# Litestream v0.3.8 – known working version with raw binary
RUN wget https://github.com/benbjohnson/litestream/releases/download/v0.3.8/litestream-linux-amd64 && \
    chmod +x litestream-linux-amd64 && \
    mv litestream-linux-amd64 litestream

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
