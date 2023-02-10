variable "proxmox_host" {
    default = "192.168.0.100"
}

#variable "ssh_key" {
#  default = "***"
#}

variable "virtual_machines" {
    default = {
        "k8s-master-node" = {
            hostname = "controlplane"
            ip_address = "192.168.0.11/24"
            gateway = "192.168.0.1",
            vlan_tag = 100,
            target_node = "pve",
            cpu_cores = 4,
            cpu_sockets = 1,
            memory = "4096",
            hdd_size = "40G",
            vm_template = "ubuntu-cloud-init",
        },
        "k8s-worker-01-node" = {
            hostname = "worker-01-node"
            ip_address = "192.168.0.12/24"
            gateway = "192.168.0.1",
            vlan_tag = 100,
            target_node = "pve",
            cpu_cores = 1,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "15G",
            vm_template = "ubuntu-cloud-init",
        },
         "k8s-worker-02-node" = {
            hostname = "worker-02-node"
            ip_address = "192.168.0.13/24"
            gateway = "192.168.0.1",
            vlan_tag = 100,
            target_node = "pve",
            cpu_cores = 1,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "15G",
            vm_template = "ubuntu-cloud-init",
        },
    }
}