.PHONY: apply init

apply:
	terraform apply -var-file="values.tfvars" -var-file="credentials.tfvars"

destroy:
	terraform destroy -var-file="values.tfvars" -var-file="credentials.tfvars"

init:
	terraform init
