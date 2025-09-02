variable "auth_url"      { type = string }
variable "region"        { type = string }
variable "user_name"     { type = string }
variable "password"      { type = string }
variable "tenant_name"   { type = string }

variable "image_name"    { type = string }
variable "flavor_name"   { type = string }
variable "network_id"    { type = string }
variable "subnet_id"     { type = string }

variable "public_key_path" { type = string }
variable "ssh_username"    { type = string }

# Nom du pool d'IP publiques (souvent "public" ou selon votre cloud)
variable "floatingip_pool" { type = string }