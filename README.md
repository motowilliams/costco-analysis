# Costco Analysis

This project contains scripts to fetch and analyze Costco receipt data using the Costco API. Note that you need to log in to costco.com manually and look at the network requests to get the bearer token, the client ID, and the client identifier.

🐳 **Docker Support**: This project now includes full Docker support with data persistence. 
- 🚀 New here? Check [QUICKSTART.md](QUICKSTART.md) for a 5-minute setup guide
- 📖 For detailed Docker documentation, see [DOCKER_README.md](DOCKER_README.md)

## Setup

### Option 1: Using Docker (Recommended)

1. Set up environment variables:

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` and add your actual Costco API credentials. You can get these by looking at the network requests in your browser when you're logged in to costco.com and looking at the headers in the graphql requests.

   - `COSTCO_BEARER_TOKEN` - Your bearer token
   - `COSTCO_CLIENT_ID` - Your client ID
   - `COSTCO_CLIENT_IDENTIFIER` - Your client identifier

2. Build the Docker container:

   ```bash
   make build
   ```

   Or without make:

   ```bash
   docker compose build
   # or for older Docker versions:
   docker-compose build
   ```

3. You're ready to use the application! See the [Docker Usage](#docker-usage) section below.

### Option 2: Local Installation

1. Install dependencies:

   With uv (recommended):
   ```bash
   uv sync
   ```

   Or with pip:
   ```bash
   pip install -r requirements.txt
   ```

2. Set up environment variables:

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` and add your actual Costco API credentials (see above).

## Scripts

- `fetch_receipts.py` - Fetches receipt lists for date ranges
- `fetch_receipt_details.py` - Fetches detailed receipt information by barcode
- `fetch_all_receipt_details.py` - Batch fetches detailed receipts for all barcodes found in data files

## Environment Variables

- `COSTCO_BEARER_TOKEN` - Your Costco API bearer token
- `COSTCO_CLIENT_ID` - Your Costco API client ID
- `COSTCO_CLIENT_IDENTIFIER` - Your Costco API client identifier

## Docker Usage

The project includes a Docker setup with data persistence. All data is stored in the `./data` directory on your host machine, which is mounted into the container.

### Quick Commands (with Makefile)

```bash
# Fetch receipt lists
make fetch-receipts

# Fetch detailed receipts for all barcodes
make fetch-all-receipts

# Generate CSV file from receipt data
make generate-csv

# Open a shell in the container
make shell

# Serve the HTML dashboard on http://localhost:8000
make serve-dashboard

# View logs
make logs

# Stop the container
make down
```

### Without Makefile

```bash
# Fetch receipt lists
docker compose run --rm costco-analysis python fetch_receipts.py

# Fetch detailed receipts
docker compose run --rm costco-analysis python fetch_all_receipt_details.py

# Generate CSV file
docker compose run --rm costco-analysis python generate_csv_file.py

# Open a shell
docker compose run --rm costco-analysis /bin/bash

# Serve the HTML dashboard
docker compose run --rm -p 8000:8000 costco-analysis python -m http.server 8000
```

*Note: For older Docker versions, use `docker-compose` instead of `docker compose`.*

### Data Persistence

All data is automatically persisted on your host machine:
- Receipt data: `./data/` directory
- CSV output: `./costco-items.csv` file
- Environment variables: `./.env` file

This works seamlessly on Windows with WSL, macOS, and Linux.

## Local Usage (Without Docker)

All scripts will automatically load the required credentials from your `.env` file. Make sure to set up all the environment variables before running any scripts.

```bash
python fetch_receipts.py
python fetch_all_receipt_details.py
```

## CSV Export

Use the `generate_csv_file.py` script to export all receipt data to CSV:

**With Docker:**
```bash
make generate-csv
# or
docker-compose run --rm costco-analysis python generate_csv_file.py
```

**Without Docker:**
```bash
python generate_csv_file.py
```

This script uses the following DuckDB query to process the JSON data and save as `costco-items.csv`:

```sql
WITH receipts AS (
    SELECT
    json_extract(data, '$.receiptsWithCounts.receipts[0]') AS r
    FROM read_json_auto('costco-analysis/data/receipts/*json')
)
SELECT
    r ->> 'transactionDate'      AS transaction_date,
    r ->> 'transactionBarcode'   AS transaction_barcode,
    r ->> 'warehouseName'        AS warehouse_name,
    item ->> 'itemNumber'        AS item_number,
    item ->> 'itemDescription01' AS description,
    item ->> 'itemDescription02' AS description2,
    description || ' ' || description2 AS combined_description,
    (item ->> 'itemUnitPriceAmount')::DOUBLE AS item_unit_price
FROM receipts,
        UNNEST(json_extract(r, '$.itemArray[*]')) AS t(item)
```
