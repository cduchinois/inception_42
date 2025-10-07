NAME        := inception

# Use HOME for dev (works on Mac and Linux), but compose files below
# will bind to absolute paths for evaluation compliance.
DATA_DIR    := $(HOME)/data

GREEN  := \033[0;32m
YELLOW := \033[1;33m
RED    := \033[0;31m
NC     := \033[0m

all: setup
	@echo "$(GREEN)Build & start$(NC)"
	@cd srcs && docker compose up -d --build

setup:
	@echo "$(YELLOW)Creating host bind volumes$(NC)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@echo "$(YELLOW)Ensuring /etc/hosts contains DOMAIN_NAME -> 127.0.0.1$(NC)"
	@DOMAIN_NAME=$$(grep -E '^DOMAIN_NAME=' srcs/.env | cut -d= -f2 | tr -d '\r'); \
	 if [ -n "$$DOMAIN_NAME" ]; then \
	   if ! grep -q "[[:space:]]$$DOMAIN_NAME\(\s\|$$\)" /etc/hosts; then \
	     echo "Adding 127.0.0.1 $$DOMAIN_NAME to /etc/hosts (sudo may prompt)"; \
	     echo "127.0.0.1 $$DOMAIN_NAME" | sudo tee -a /etc/hosts >/dev/null; \
	   else \
	     echo "Hosts entry for $$DOMAIN_NAME already present"; \
	   fi; \
	 else \
	   echo "$(RED)DOMAIN_NAME not set in srcs/.env; skipping hosts update$(NC)"; \
	 fi

down:
	@cd srcs && docker compose down

start:
	@cd srcs && docker compose start

stop:
	@cd srcs && docker compose stop

clean: down
	@echo "$(YELLOW)Compose prune volumes$(NC)"
	@cd srcs && docker compose down -v

fclean: clean
	@echo "$(RED)Remove host data at $(DATA_DIR)$(NC)"
	@rm -rf $(DATA_DIR)

re: fclean all

logs:
	@cd srcs && docker compose logs -f

ps:
	@cd srcs && docker compose ps
