FROM alpine:latest

RUN apk add --no-cache wget unzip ca-certificates curl bash

WORKDIR /app

# PocketBase v0.39.10 (fixed)
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_linux_amd64.zip && \
    unzip pocketbase_0.39.10_linux_amd64.zip && \
    rm pocketbase_0.39.10_linux_amd64.zip && \
    chmod +x pocketbase

# Install Litestream using the official install script (always works)
RUN curl -fsSL https://litestream.io/install.sh | bash && \
    mv /usr/local/bin/litestream /app/litestream

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
