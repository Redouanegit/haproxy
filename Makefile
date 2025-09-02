TF_DIR=terraform
ANSIBLE_DIR=ansible

.PHONY: tf-init tf-plan tf-apply tf-destroy ansible

tf-init:
	cd $(TF_DIR) && terraform init

tf-plan: tf-init
	cd $(TF_DIR) && terraform plan

tf-apply: tf-init
	cd $(TF_DIR) && terraform apply -auto-approve

ansible:
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../terraform/inventory.ini playbook.yml

tf-destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve