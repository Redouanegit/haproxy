[all:vars]
ansible_user=${ssh_username}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[lb]
lb ansible_host=${lb_fip} private_ip=${lb_priv_ip}

[apps]
# Les backends vers lesquels HAProxy enverra le trafic (IP privées)
lb ansible_host=${lb_fip} private_ip=${lb_priv_ip}
app2 ansible_host=${app2_fip} private_ip=${app2_priv_ip}