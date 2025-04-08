.PHONY: test clean-repos setup-repos help test-% setup-repo-% clean-repo-% list-scenarios build clean

# Variables
SHELL := /bin/bash
TEST_DIR := test
REPOS_DIR := $(TEST_DIR)/repos
DIST_DIR := dist
VERSION ?= $(shell git describe --tags --always --abbrev=7 2>/dev/null || date +'%Y%m%d-%H%M%S')

# Extract command type (gen/up) and scenario from target name
CMD = $(firstword $(subst -, ,$*))
SCENARIO = $(subst $(CMD)-,,$*)

setup-repos: ## Initialize all test repositories
	@echo "Initializing all test repositories..."
	@$(TEST_DIR)/init-repos.sh

setup-repo-%: ## Initialize a specific test repository (e.g. make setup-repo-gen-clean, setup-repo-up-staged)
	@if [ "$(CMD)" != "gen" ] && [ "$(CMD)" != "up" ]; then \
		echo "Error: Invalid command type. Use 'gen' or 'up'"; \
		exit 1; \
	fi
	@if [ -n "$(SCENARIO)" ]; then \
		echo "Initializing git-$(CMD) $(SCENARIO) test repository..."; \
		$(TEST_DIR)/init-repos.sh -s $(SCENARIO) -c $(CMD); \
	else \
		echo "Initializing all git-$(CMD) test repositories..."; \
		$(TEST_DIR)/init-repos.sh -c $(CMD); \
	fi

test: setup-repos ## Run all tests across different scenarios
	@echo "Running all tests..."
	@echo "Running git-gen tests..."
	@for test in $(TEST_DIR)/scenarios/gen/*.exp; do \
		scenario=$$(basename $$test .exp); \
		$$test $(REPOS_DIR)/gen_$$scenario; \
	done
	@echo "Running git-up tests..."
	@for test in $(TEST_DIR)/scenarios/up/*.exp; do \
		scenario=$$(basename $$test .exp); \
		$$test $(REPOS_DIR)/up_$$scenario; \
	done

test-%: setup-repo-% ## Run tests (e.g. make test-gen-clean, test-up-staged, test-gen, test-up)
	@if [ "$(CMD)" != "gen" ] && [ "$(CMD)" != "up" ]; then \
		echo "Error: Invalid command type. Use 'gen' or 'up'"; \
		exit 1; \
	fi
	@if [ -n "$(SCENARIO)" ]; then \
		echo "Running git-$(CMD) tests for $(SCENARIO) scenario..."; \
		$(TEST_DIR)/scenarios/$(CMD)/$(SCENARIO).exp $(REPOS_DIR)/$(CMD)_$(SCENARIO); \
	else \
		echo "Running all git-$(CMD) tests..."; \
		for test in $(TEST_DIR)/scenarios/$(CMD)/*.exp; do \
			scenario=$$(basename $$test .exp); \
			$$test $(REPOS_DIR)/$(CMD)_$$scenario; \
		done; \
	fi

clean-repos: ## Remove all test repositories
	@echo "Cleaning all test repositories..."
	@rm -rf $(REPOS_DIR)

clean-repo-%: ## Remove a specific test repository (e.g. make clean-repo-gen-staged, clean-repo-up-staged)
	@if [ "$(CMD)" != "gen" ] && [ "$(CMD)" != "up" ]; then \
		echo "Error: Invalid command type. Use 'gen' or 'up'"; \
		exit 1; \
	fi
	@if [ -n "$(SCENARIO)" ]; then \
		echo "Cleaning git-$(CMD) $(SCENARIO) test repository..."; \
		rm -rf $(REPOS_DIR)/$(CMD)_$(SCENARIO); \
	else \
		echo "Cleaning all git-$(CMD) test repositories..."; \
		rm -rf $(REPOS_DIR)/$(CMD)_*; \
	fi

list-scenarios: ## List available test scenarios
	@echo "Available test scenarios:"
	@echo "git-gen scenarios:"
	@ls -1 $(TEST_DIR)/scenarios/gen | sed 's/\.exp//' | sed 's/^/  - /'
	@echo
	@echo "git-up scenarios:"
	@ls -1 $(TEST_DIR)/scenarios/up | sed 's/\.exp//' | sed 's/^/  - /'

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z0-9_-]+[^%]:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-28s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Pattern rules:"
	@grep -E '^[a-zA-Z0-9_-]+%:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-28s\033[0m %s\n", $$1, $$2}'

clean: ## Clean build artifacts
	@rm -rf $(DIST_DIR)

build: clean ## Build release package
	@mkdir -p $(DIST_DIR)/temp
	@rsync -a --exclude={'.git','.github','dist','cfg','test'} . $(DIST_DIR)/temp/ >/dev/null
	@cd $(DIST_DIR)/temp && tar -czf "../git-assist-$(VERSION).tar.gz" .
	@rm -rf $(DIST_DIR)/temp
	@echo "Release package created at $(DIST_DIR)/git-assist-$(VERSION).tar.gz"

.DEFAULT_GOAL := help 