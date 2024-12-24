FROM debian:sid-slim

# Set build-time variables for UID and GID
ARG USER_ID=10000
ARG GROUP_ID=10000

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create a group and user with the host IDs so we can execute binary to extract version info
RUN groupadd -g 1000 ubuntu && \
    useradd -u 1000 -g ubuntu -m ubuntu

# Install the hl_exporter binary as root user
RUN curl -sSL $(curl -s https://api.github.com/repos/validaoxyz/hyperliquid-exporter/releases/latest \
    | jq -r '.assets[] | select(.name | contains("linux_amd64") and (endswith(".tar.gz") | not)) | .browser_download_url') \
    -o /usr/local/bin/hl_exporter && \
    chmod +x /usr/local/bin/hl_exporter

# Switch to the new user
USER ubuntu

# Set working directory
WORKDIR /app

# Use ENTRYPOINT with shell form to allow environment variable expansion
ENTRYPOINT /usr/local/bin/hl_exporter start --chain ${CHAIN,,}
