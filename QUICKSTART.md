# Quick Start Guide

Get started with Costco Analysis in 5 minutes using Docker! 🚀

## Prerequisites

- Docker Desktop installed (includes Docker Compose)
- For Windows: WSL2 enabled

## Setup (5 minutes)

### 1. Clone and Configure (2 minutes)

```bash
# Clone the repository
git clone https://github.com/motowilliams/costco-analysis.git
cd costco-analysis

# Copy environment template
cp .env.example .env

# Edit .env with your credentials
# Get these from costco.com network requests
nano .env  # or use your favorite editor
```

### 2. Build Docker Image (2 minutes)

```bash
make build
```

Or without make:
```bash
docker compose build
```

### 3. Start Using! (1 minute)

```bash
# Fetch your Costco receipts
make fetch-receipts

# Get detailed receipt information
make fetch-all-receipts

# Generate CSV analysis
make generate-csv

# View the dashboard
make serve-dashboard
# Open http://localhost:8000/index.html in your browser
```

## Common Commands

```bash
make help              # See all available commands
make shell             # Open bash shell in container
make fetch-receipts    # Fetch receipt data
make generate-csv      # Generate analysis CSV
make serve-dashboard   # Serve web dashboard
make down              # Stop container
make clean             # Remove everything
```

## Where's My Data?

All data is stored on your computer (not in the container):

- `./data/receipts/*.json` - Your receipt data
- `./costco-items.csv` - Generated analysis
- `./.env` - Your credentials (never committed to Git)

## Troubleshooting

### "Command not found: make"

Use Docker commands directly:
```bash
docker compose build
docker compose run --rm costco-analysis python fetch_receipts.py
```

### "Permission denied" on Linux

Run with your user:
```bash
docker compose run --rm --user $(id -u):$(id -g) costco-analysis /bin/bash
```

### Data not saving

Make sure the `./data` directory exists:
```bash
mkdir -p data/receipts
```

### Windows WSL Issues

1. Store project in WSL filesystem (not `/mnt/c/...`)
2. Use WSL terminal for Docker commands
3. Enable WSL2 integration in Docker Desktop

## Next Steps

- 📖 Read [DOCKER_README.md](DOCKER_README.md) for detailed documentation
- 📊 View [DASHBOARD_README.md](DASHBOARD_README.md) for dashboard features
- 🔧 Check [README.md](README.md) for script details

## Getting Credentials

To get your Costco API credentials:

1. Go to https://www.costco.com and log in
2. Open your browser's Developer Tools (F12)
3. Go to the "Network" tab
4. Navigate to your order history
5. Look for GraphQL requests to `ecom-api.costco.com`
6. Check the request headers for:
   - `costco-x-authorization: Bearer <token>` → COSTCO_BEARER_TOKEN
   - `costco-x-wcs-clientId: <id>` → COSTCO_CLIENT_ID
   - `client-identifier: <identifier>` → COSTCO_CLIENT_IDENTIFIER

## Support

- Check the comprehensive [DOCKER_README.md](DOCKER_README.md)
- Review Docker Compose configuration with: `docker compose config`
- View container logs: `make logs` or `docker compose logs`

Happy analyzing! 📊🛒
