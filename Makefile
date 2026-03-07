from ?=
out ?=

TEMPLATES := go-node-container typescript-node-container terraform-container arch-container
DEPLOY_FROM := $(strip $(if $(from),$(from),typescript-node-container))
DEPLOY_OUT := $(strip $(out))

.PHONY: help list deploy

help:
	@echo "Usage:"
	@echo "  make deploy out=/path/to/project [from=typescript-node-container|go-node-container|terraform-container|arch-container]"
	@echo "  make list"

list:
	@echo "Available templates:"
	@for t in $(TEMPLATES); do echo "  - $$t"; done

deploy:
	@test -n "$(DEPLOY_OUT)" || (echo "ERROR: out is required. e.g. make deploy out=/Users/you/project" && exit 1)
	@test -d "$(DEPLOY_FROM)" || (echo "ERROR: from '$(DEPLOY_FROM)' not found" && exit 1)
	@mkdir -p "$(DEPLOY_OUT)"
	@cp -a "$(DEPLOY_FROM)/." "$(DEPLOY_OUT)/"
	@echo "Deployed '$(DEPLOY_FROM)' to $(DEPLOY_OUT)"
