default: help

SHELL := bash

.PHONY: clean
clean: ## Remove all build targets
	@rm -r output/*

deploy: ## Runs terraform
	@scripts/deploy.sh

check-lambda: ## Checks for the Lambda
	@scripts/check_lambda.sh

check-peering: ## Checks for the Lambda
	@scripts/check_peering.sh

.PHONY: help
help: ## Display this information. Default target.
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
