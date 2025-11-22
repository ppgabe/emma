FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libz1 && rm -rf /var/lib/apt/lists/*

COPY target/emma-server /app/emma-server

ENTRYPOINT ["/app/emma-server"]