DEVCONTAINER ?= devcontainer
WORKSPACE_DIR := .
FORCE ?= 0

REMOVE_FLAG :=
ifeq ($(FORCE),1)
REMOVE_FLAG := --remove-existing-container
endif

.PHONY: up zsh bash rebuild

up:
	$(DEVCONTAINER) up --workspace-folder $(WORKSPACE_DIR) $(REMOVE_FLAG)

zsh:
	$(DEVCONTAINER) exec --workspace-folder $(WORKSPACE_DIR) zsh
bash:
	$(DEVCONTAINER) exec --workspace-folder $(WORKSPACE_DIR) bash

rebuild:
	$(DEVCONTAINER) up --workspace-folder $(WORKSPACE_DIR) --remove-existing-container
