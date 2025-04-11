output "private_key" {
    value = tls_private_key.linux_ssh_key.private_key_pem
    description = "private key of provisioned instance"
    sensitive = true
}

output "vm_username" {
    value = azurerm_virtual_machine.linux_vm.os_profile
    description = "public IP address used by the VM"
    sensitive = true
}

output "vm_ip_address" {
    value = azurerm_public_ip.vm_public_ip.ip_address
    description = "public IP address used by the VM"
    sensitive = false
}