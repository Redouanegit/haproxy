

# terraform-ansible-haproxy (OpenStack)

Ce projet provisionne 2 VMs sur OpenStack avec Terraform et configure :
- NGINX (port 8080) sur **les deux** VMs
- HAProxy sur la VM `lb` (IP publique) qui load-balance vers les **IP privées** des deux VMs

## Prérequis
- Terraform >= 1.3
- Ansible >= 2.14
- Accès OpenStack (variables d'environnement ou `terraform.tfvars`)
- Une clé SSH (publique) accessible localement

## Variables à fournir
Créez `terraform/terraform.tfvars` avec vos valeurs :

```hcl
auth_url      = "https://openstack.example.com:5000/v3"
region        = "RegionOne"
user_name     = "myuser"
password      = "mypassword"
tenant_name   = "myproject"
image_name    = "Ubuntu 22.04"
flavor_name   = "m1.small"
network_id    = "<UUID reseau privé>"
subnet_id     = "<UUID subnet privé>"
public_key_path = "~/.ssh/id_rsa.pub"
ssh_username  = "ubuntu" # selon l'image