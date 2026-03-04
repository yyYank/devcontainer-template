TEMPLATE ?= typescript-node-container
OUT ?=

TEMPLATES := go-node-container typescript-node-container

.PHONY: help list deploy

help:
	@echo "Usage:"
	@echo "  make deploy OUT=/path/to/project [TEMPLATE=typescript-node-container|go-node-container]"
	@echo "  make list"

list:
	@echo "Available templates:"
	@for t in $(TEMPLATES); do echo "  - $$t"; done

deploy:
	@test -n "$(OUT)" || (echo "ERROR: OUT is required. e.g. make deploy OUT=/Users/you/project" && exit 1)
	@test -d "$(TEMPLATE)" || (echo "ERROR: TEMPLATE '$(TEMPLATE)' not found" && exit 1)
	@mkdir -p "$(OUT)"
	@cp -a "$(TEMPLATE)/." "$(OUT)/"
	@echo "Deployed '$(TEMPLATE)' to $(OUT)"
