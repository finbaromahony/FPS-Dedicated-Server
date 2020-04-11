TERRAFORM=terraform
FMT=fmt
PLAN=plan
APPLY=apply
VALIDATE=validate
ECHO=echo
INIT=init
WORKSPACE=counter-strike-instance-workspace

# Default build target
.DEFAULT_GOAL := validate

# Linting using Terraform FMT
.PHONY: fmt
fmt:
	@$(ECHO) "Format terraform files"
	@cd ./src/terraform/; $(TERRAFORM) $(FMT) -recursive
	@$(ECHO) "Finished formatting files"

.PHONY: init
init:
	@$(ECHO) "Perform terraform init"
	@cd ./src/terraform; $(TERRAFORM) $(INIT)
	@$(ECHO) "Finished terraform init"

.PHONY: select_workspace
select_workspace: init
	@$(ECHO) "select $(WORKSPACE) workspace"
	@cd ./src/terraform; $(TERRAFORM) workspace new $(WORKSPACE) ||:
	@cd ./src/terraform; $(TERRAFORM) workspace select $(WORKSPACE)
	@$(ECHO) "$(WORKSPACE) workspace selected"

.PHONY: apply
apply: select_workspace
	@$(ECHO) "apply to $(WORKSPACE)"
	@cd ./src/terraform; $(TERRAFORM) apply --auto-approve
	@$(ECHO) "deployment in workspace $(WORKSPACE) applied"

.PHONY: destroy
destroy: select_workspace
	@$(ECHO) "destroy deployment at workspace $(WORKSPACE)"
	@cd ./src/terraform; $(TERRAFORM) destroy --auto-approve
	@$(ECHO) "deployment in workspace $(WORKSPACE) destroyed"

.PHONY: output
output: select_workspace
	@$(ECHO) "export output from $(WORKSPACE)"
	@cd ./src/terraform; $(TERRAFORM) output --json > ../../terraform_output.json
