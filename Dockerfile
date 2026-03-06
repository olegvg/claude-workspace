FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code@latest

RUN useradd -m -s /bin/bash coder
USER coder
WORKDIR /workspace

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
