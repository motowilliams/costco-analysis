.PHONY: help build up down shell fetch-receipts fetch-all-receipts generate-csv clean logs

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker compose build

up: ## Start the container in detached mode
	docker compose up -d

down: ## Stop and remove the container
	docker compose down

shell: ## Open a shell in the container
	docker compose run --rm costco-analysis /bin/bash

fetch-receipts: ## Run fetch_receipts.py script
	docker compose run --rm costco-analysis python fetch_receipts.py

fetch-all-receipts: ## Run fetch_all_receipt_details.py script
	docker compose run --rm costco-analysis python fetch_all_receipt_details.py

generate-csv: ## Run generate_csv_file.py script
	docker compose run --rm costco-analysis python generate_csv_file.py

serve-dashboard: ## Serve the HTML dashboard (port 8000)
	docker compose run --rm -p 8000:8000 costco-analysis python -m http.server 8000

logs: ## Show container logs
	docker compose logs -f

clean: ## Remove container, images, and volumes
	docker compose down -v --rmi all

restart: down up ## Restart the container
