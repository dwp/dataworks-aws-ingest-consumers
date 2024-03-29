SHELL:=bash

aws_profile=default
aws_region=eu-west-2

default: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Bootstrap local environment for first use
	@make git-hooks
	pip3 install --user Jinja2 PyYAML boto3
	@{ \
		export AWS_PROFILE=$(aws_profile); \
		export AWS_REGION=$(aws_region); \
		python3 bootstrap_terraform.py; \
	}
	terraform fmt -recursive

.PHONY: git-hooks
git-hooks: ## Set up hooks in .githooks
	@git submodule update --init .githooks ; \
	git config core.hooksPath .githooks \

.PHONY: concourse-login
concourse-login: ## Login to concourse using Fly
	fly -t aws-concourse login -c https://ci.dataworks.dwp.gov.uk/ -n dataworks

.PHONY: utility-login
utility-login: ## Login to utility team using Fly
	fly -t utility login -c https://ci.dataworks.dwp.gov.uk/ -n utility

.PHONY: update-pipeline
update-pipeline: ## Update the main pipeline
	aviator

.PHONY: update-corporate-storage-coalescence-pipeline
update-corporate-storage-coalescence-pipeline: ## Update the corporate-storage-coalescence pipeline
	aviator -f aviator-corporate-storage-coalescence.yml

.PHONY: update-k2hb-reconciliation-trimmer-pipeline
update-k2hb-reconciliation-trimmer-pipeline: ## Update the k2hb-reconciliation-trimmer pipeline
	aviator -f aviator-k2hb-reconciliation-trimmer.yml

.PHONY: terraform-init
terraform-init: ## Run `terraform init` from repo root
	terraform init

.PHONY: terraform-plan
terraform-plan: ## Run `terraform plan` from repo root
	terraform plan

.PHONY: terraform-apply
terraform-apply: ## Run `terraform apply` from repo root
	terraform apply

.PHONY: terraform-workspace-new
terraform-workspace-new: ## Creates new Terraform workspace with Concourse remote execution. Run `terraform-workspace-new workspace=<workspace_name>`
	declare -a workspace=( qa integration preprod production ) \
	make bootstrap ; \
	cp terraform.tf jeff.tf && \
	for i in "$${workspace[@]}" ; do \
		fly -t aws-concourse execute --config create-workspace.yml --input repo=. -v workspace="$$i" ; \
	done
	rm jeff.tf
