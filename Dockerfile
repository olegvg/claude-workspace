FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1000 coder
USER coder
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/claude", "--dangerously-skip-permissions"]
