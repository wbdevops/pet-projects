provider "proxmox" {
    pm_api_url = "https://${var.proxmox_host}:8006/api2/json"
    pm_tls_insecure = true

    # Uncomment the below for debugging.
    # pm_log_enable = true
    # pm_log_file = "terraform-plugin-proxmox.log"
    # pm_debug = true
    # pm_log_levels = {
    # _default = "debug"
    # _capturelog = ""
    # }
}

resource "proxmox_vm_qemu" "virtual_machines" {
    for_each = var.virtual_machines

    name = each.value.hostname
    target_node = each.value.target_node
    clone = each.value.vm_template
    agent = 1
    os_type = "cloud-init"
    cores = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    cpu = "host"
    memory = each.value.memory
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = each.value.hdd_size
        type = "scsi"
        storage = "local-lvm"
        iothread = 0
    }
    
    network {
        model = "virtio"
        bridge = "vmbr0"
   	    #tag = each.value.vlan_tag
    }

    # Not sure exactly what this is for. something about 
    # ignoring network changes during the life of the VM.
    lifecycle {
        ignore_changes = [
        network,
        ]
    }

    # Cloud-init config
    ipconfig0 = "ip=${each.value.ip_address},gw=${each.value.gateway}"
    #sshkeys = var.ssh_key - require uncoment ssh_key variable in vars.tf
}

output "vm_ipv4_addresses" {
  value = {
      for instance in proxmox_vm_qemu.virtual_machines:
      instance.name => instance.default_ipv4_address
  }
}