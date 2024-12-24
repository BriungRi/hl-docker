# Running a Hyperliquid Node with Docker

## Prerequisites
- Docker and Docker Compose installed
- Git
- Ubuntu 24.04 (recommended)
- Open ports 4000-4010 for gossip communication

## Hardware Requirements
- 4 CPU cores
- 16 GB RAM
- 50 GB disk
- Lowest latency, run in Tokyo, Japan
- Minimum latency must be <200ms from 1/3 of validators

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/BriungRi/hl-docker.git
cd hl-docker
```

2. Create a `.env` file with your configuration:
```bash
# Required
CHAIN=testnet          # or mainnet
VALIDATOR=false        # true for validator nodes
PRUNER=true           # enables automatic data pruning

# Optional - Only required for validators
SIGNER_KEY=           # your validator signer key
OVERRIDE_PEER_IPS=    # comma-separated list of peer IPs
OVERRIDE_TRY_NEW_PEERS=true  # whether to try finding new peers
```

3. Start the node:
```bash
./hld up
```

## Available Commands

The `hld` CLI tool provides several commands:

- `./hld up` - Start containers
- `./hld down` - Stop and remove containers
- `./hld restart` - Restart containers
- `./hld logs [service]` - View logs (optionally for a specific service)
- `./hld exec <service>` - Execute shell in a container (validator/node/pruner)
- `./hld update` - Update code and rebuild containers
- `./hld vstatus <validator>` - Check validator status
- `./hld vtop [N]` - List top N validators by stake

## Monitoring

The stack includes:
- Prometheus metrics exporter (port 8086)
- Prometheus server (port 9099)
- Grafana dashboards (port 3000)
- Node exporter for system metrics

Access Grafana at http://localhost:3000 (default credentials: admin/admin)

## Data Management

Node data is stored in Docker volumes:
- `hl-data`: Node data and logs
- `hl-home`: Home directory data
- `prometheus_data`: Metrics storage
- `grafana_data`: Dashboard configurations

The pruner service automatically cleans old data daily to prevent disk space issues.

## Validator Setup

For validator nodes, additional configuration is required. See the [Official HL node repo](https://github.com/hyperliquid-dex/node) for detailed instructions.

## Troubleshooting

- Check container logs: `./hld logs <service>`
- Access container shell: `./hld exec <service>`
- View crash logs in `~/hl/data/visor_child_stderr/`
- Monitor system metrics in Grafana

## License

MIT License - See LICENSE file for details
