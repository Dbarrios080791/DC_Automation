# =============================================================================
# DC Network as Code - punto de entrada único.   `make help`
# =============================================================================
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Carga .env si existe (credenciales, nunca en git)
ifneq (,$(wildcard .env))
include .env
export
endif

PYTHON ?= python3.12
VENV   := .venv
BIN    := $(VENV)/bin
TF     ?= terraform

LAB    ?=
WS      = $(subst /,-,$(LAB))
GROUPS ?= []
DEVICES ?= []

NXOS_DIR := nac/nxos
ACI_DIR  := nac/aci
CML_DIR  := cml/terraform

##@ Entorno
.PHONY: setup
setup: ## Crea .venv, instala dependencias Python, colecciones Ansible y hooks
	$(PYTHON) -m venv $(VENV)
	$(BIN)/pip install --upgrade pip
	$(BIN)/pip install -r requirements.txt
	cd ansible && ../$(BIN)/ansible-galaxy collection install -r requirements.yml -p ./collections
	$(BIN)/pre-commit install
	@test -f .env || (cp .env.example .env && echo ">> Creado .env: rellena tus credenciales")

.PHONY: lint
lint: ## Ejecuta todos los linters (pre-commit)
	$(BIN)/pre-commit run --all-files

.PHONY: test
test: ## Tests Python offline (reglas NaC, inventario)
	$(BIN)/pytest

##@ Labs en CML (clases y fabric NaC)
.PHONY: lab-new
lab-new: ## Crea un lab de clase desde la plantilla: make lab-new NAME=03-ospf
	@test -n "$(NAME)" || (echo "Uso: make lab-new NAME=03-ospf" && exit 1)
	@test ! -e labs/nxos/$(NAME) || (echo "labs/nxos/$(NAME) ya existe" && exit 1)
	cp -R labs/nxos/_template labs/nxos/$(NAME)
	sed -i.bak "s/__LAB_NAME__/$(NAME)/g" labs/nxos/$(NAME)/topology.yaml labs/nxos/$(NAME)/README.md
	rm -f labs/nxos/$(NAME)/*.bak
	@echo ">> Listo: make lab-up LAB=labs/nxos/$(NAME)"

.PHONY: _lab-check
_lab-check:
	@test -n "$(LAB)" || (echo "Indica el lab: LAB=labs/nxos/03-ospf o LAB=nac/nxos/cml" && exit 1)
	@$(TF) -chdir=$(CML_DIR) init -input=false >/dev/null
	@$(TF) -chdir=$(CML_DIR) workspace select -or-create $(WS) >/dev/null

.PHONY: lab-up
lab-up: _lab-check ## Crea/arranca un lab:   make lab-up LAB=nac/nxos/cml
	$(TF) -chdir=$(CML_DIR) apply -auto-approve -var lab_path=$(LAB) -var lab_state=STARTED

.PHONY: lab-down
lab-down: _lab-check ## Apaga un lab (conserva config): make lab-down LAB=...
	$(TF) -chdir=$(CML_DIR) apply -auto-approve -var lab_path=$(LAB) -var lab_state=STOPPED

.PHONY: lab-destroy
lab-destroy: _lab-check ## Borra el lab de CML (pide confirmación)
	$(TF) -chdir=$(CML_DIR) destroy -var lab_path=$(LAB)

.PHONY: lab-list
lab-list: ## Lista los labs gestionados (workspaces)
	@$(TF) -chdir=$(CML_DIR) workspace list

##@ Network as Code - NX-OS
.PHONY: nxos-validate
nxos-validate: ## Validación sintáctica + semántica de nac/nxos/data
	$(BIN)/nac-validate -r $(NXOS_DIR)/rules $(NXOS_DIR)/data

.PHONY: nxos-init
nxos-init:
	$(TF) -chdir=$(NXOS_DIR) init -input=false

.PHONY: nxos-plan
nxos-plan: nxos-validate nxos-init ## Plan (opcional GROUPS='["spines"]' DEVICES='["leaf1"]')
	$(TF) -chdir=$(NXOS_DIR) plan -out=nxos.tfplan \
	  -var 'managed_device_groups=$(GROUPS)' -var 'managed_devices=$(DEVICES)'

.PHONY: nxos-apply
nxos-apply: ## Aplica el último plan revisado
	$(TF) -chdir=$(NXOS_DIR) apply nxos.tfplan

##@ Network as Code - ACI
.PHONY: aci-validate
aci-validate: ## Validación sintáctica de nac/aci/data
	$(BIN)/nac-validate $(ACI_DIR)/data

.PHONY: aci-plan
aci-plan: aci-validate ## Plan contra el simulador APIC
	$(TF) -chdir=$(ACI_DIR) init -input=false
	$(TF) -chdir=$(ACI_DIR) plan -out=aci.tfplan

.PHONY: aci-apply
aci-apply: ## Aplica el último plan revisado de ACI
	$(TF) -chdir=$(ACI_DIR) apply aci.tfplan

##@ Operación (día 2)
.PHONY: verify
verify: ## Verifica OSPF / BGP EVPN / NVE contra el estado esperado (Ansible)
	cd ansible && ../$(BIN)/ansible-playbook playbooks/verify-fabric.yml

.PHONY: backup
backup: ## Respaldo de running-config del fabric en ansible/backups/
	cd ansible && ../$(BIN)/ansible-playbook playbooks/backup.yml

.PHONY: inventory
inventory: ## Inventario por NX-API (modelo, versión, serial)
	$(BIN)/python python/offbox/nxapi_inventory.py

.PHONY: deploy
deploy: nxos-plan ## Flujo completo: validar -> plan -> (confirmar) apply -> verificar
	@read -p "¿Aplicar el plan anterior? [y/N] " ans && [ "$$ans" = "y" ]
	$(MAKE) nxos-apply
	$(MAKE) verify

##@ Ayuda
.PHONY: help
help: ## Muestra esta ayuda
	@awk 'BEGIN {FS = ":.*##"; printf "\nUso: make \033[36m<objetivo>\033[0m\n"} \
	  /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
	  /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)
