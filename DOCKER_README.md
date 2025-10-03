# Docker Setup Guide

This guide explains how to use Docker with the Costco Analysis project. The Docker setup provides a consistent environment and works seamlessly on Windows (WSL), macOS, and Linux.

## Prerequisites

- Docker installed on your system
- Docker Compose (usually comes with Docker Desktop)
- For Windows: WSL2 (Windows Subsystem for Linux 2)

## Quick Start

1. **Set up environment variables:**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your Costco API credentials.

2. **Build the Docker image:**

   ```bash
   make build
   ```

   Or without make:

   ```bash
   docker compose build
   ```

3. **Run scripts:**

   ```bash
   # Fetch receipts
   make fetch-receipts

   # Generate CSV
   make generate-csv

   # Open a shell
   make shell
   ```

## How It Works

### Data Persistence

The Docker setup uses **volume mounting** to ensure all your data persists on your host machine:

- `./data` → `/app/data` - All receipt JSON files
- `./.env` → `/app/.env` - Environment variables (read-only)
- `./costco-items.csv` → `/app/costco-items.csv` - Generated CSV output

This means:
- Your data survives container restarts
- You can access files directly on your host machine
- No data is lost when containers are removed

### Windows WSL Compatibility

The Docker setup works perfectly with Windows and WSL:

1. **File paths**: Use forward slashes (`/`) even on Windows - Docker handles this automatically
2. **Line endings**: The Docker image uses Linux line endings, avoiding any Windows CRLF issues
3. **Performance**: Store your project in WSL filesystem (e.g., `~/projects/costco-analysis`) for better performance
4. **Access**: You can edit files in Windows (VS Code, etc.) and run in Docker seamlessly

## Available Make Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make build` | Build the Docker image |
| `make shell` | Open an interactive bash shell in the container |
| `make fetch-receipts` | Run the fetch_receipts.py script |
| `make fetch-all-receipts` | Run the fetch_all_receipt_details.py script |
| `make generate-csv` | Generate CSV from receipt data |
| `make serve-dashboard` | Serve the HTML dashboard on port 8000 |
| `make up` | Start container in detached mode |
| `make down` | Stop and remove containers |
| `make logs` | Show container logs |
| `make clean` | Remove containers, images, and volumes |
| `make restart` | Restart the container |

## Manual Docker Commands

If you don't have `make` installed, you can use these Docker commands directly:

```bash
# Build the image
docker compose build

# Run a script
docker compose run --rm costco-analysis python fetch_receipts.py
docker compose run --rm costco-analysis python generate_csv_file.py

# Open a shell
docker compose run --rm costco-analysis /bin/bash

# Serve the dashboard
docker compose run --rm -p 8000:8000 costco-analysis python -m http.server 8000

# Clean up
docker compose down
docker compose down -v --rmi all  # Remove everything including volumes and images
```

## Working Inside the Container

When you open a shell with `make shell`:

```bash
# You're in /app directory
pwd  # /app

# All Python scripts are available
python fetch_receipts.py
python generate_csv_file.py

# Data is in /app/data
ls data/receipts

# Environment variables are loaded from .env
echo $COSTCO_BEARER_TOKEN
```

## Troubleshooting

### Permission Issues on Linux

If you encounter permission issues with mounted volumes:

```bash
# Run container as your user
docker compose run --rm --user $(id -u):$(id -g) costco-analysis /bin/bash
```

### Windows Path Issues

If you're on Windows and have path issues:

1. Make sure your project is in WSL filesystem (not `/mnt/c/...`)
2. Use WSL terminal (Ubuntu, etc.) to run Docker commands
3. Docker Desktop for Windows should have WSL2 integration enabled

### Data Not Persisting

If your data isn't persisting:

1. Check that the `./data` directory exists on your host
2. Verify volumes are mounted: `docker compose config`
3. Don't use `docker compose down -v` (this removes volumes)

### Rebuilding After Changes

If you modify Python files:

```bash
# No rebuild needed - files are copied during build
# Just run the script again

# If you modify requirements.txt or Dockerfile:
make build
```

## Environment Variables

The following environment variables are loaded from your `.env` file:

- `COSTCO_BEARER_TOKEN` - Your Costco API bearer token
- `COSTCO_CLIENT_ID` - Your Costco API client ID  
- `COSTCO_CLIENT_IDENTIFIER` - Your Costco API client identifier

These are automatically passed into the container via `docker-compose.yml`.

## Best Practices

1. **Never commit `.env`** - It contains sensitive credentials
2. **Use volumes for data** - Don't store data inside containers
3. **Rebuild after dependency changes** - Run `make build` after updating requirements.txt
4. **Clean up regularly** - Use `make clean` to remove old images
5. **Check logs** - Use `make logs` to debug issues

## Advanced Usage

### Running Multiple Instances

You can run multiple commands simultaneously:

```bash
# Terminal 1
make serve-dashboard

# Terminal 2  
make shell
```

### Custom Python Commands

```bash
# Run any Python script
docker compose run --rm costco-analysis python your_script.py

# Run Python interactively
docker compose run --rm costco-analysis python

# Install additional packages (temporary)
docker compose run --rm costco-analysis pip install pandas
```

### Accessing the Dashboard

When you run `make serve-dashboard`, the HTML dashboard is served on:
- http://localhost:8000/index.html
- Works on Windows (even in WSL), macOS, and Linux
- Access from your browser on the host machine

## Security Notes

- The `.env` file is mounted read-only (`:ro`) for security
- Credentials are never built into the Docker image
- Use `.dockerignore` to prevent sensitive files from being copied

## Support

For issues specific to Docker setup, check:
1. Docker is running: `docker ps`
2. Compose is working: `docker compose version`
3. Volumes are correct: `docker compose config`
