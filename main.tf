terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

locals {
  common_network_adapter = {
    type           = "bridged"
    host_interface = "wlan0"
  }

  common_image = "${path.module}/virtualbox.box"
}

resource "virtualbox_vm" "master" {
  name      = "master"
  cpus      = 2
  memory    = "2.0 GiB"
  image     = local.common_image
  status    = "running"

  network_adapter {
    type           = local.common_network_adapter.type
    host_interface = local.common_network_adapter.host_interface
  }

  provisioner "file" {
    source      = "${path.module}/base_conf.sh"
    destination = "/tmp/base_conf.sh"

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }

  provisioner "file" {
    source      = "${path.module}/network.sh"
    destination = "/tmp/network.sh"

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }
  

  provisioner "remote-exec" {
    inline = [
      "export NEW_HOSTNAME=${self.name}",
      "chmod +x /tmp/base_conf.sh",
      "/tmp/base_conf.sh",
      "chmod +x /tmp/network.sh",
      "/tmp/network.sh"
    ]

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }
}

resource "virtualbox_vm" "node" {
  count     = 2
  name      = "node-${count.index + 1}"
  cpus      = 1
  memory    = "1.0 GiB"
  image     = local.common_image
  status    = "running"

  depends_on = [virtualbox_vm.master]

  network_adapter {
    type           = local.common_network_adapter.type
    host_interface = local.common_network_adapter.host_interface
  }

  provisioner "file" {
    source      = "${path.module}/base_conf.sh"
    destination = "/tmp/base_conf.sh"

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }

  provisioner "file" {
    source      = "${path.module}/network.sh"
    destination = "/tmp/network.sh"

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }

  provisioner "remote-exec" {
    inline = [
      "export NEW_HOSTNAME=${self.name}",
      "chmod +x /tmp/base_conf.sh",
      "/tmp/base_conf.sh",
      "chmod +x /tmp/network.sh",
      "/tmp/network.sh"
    ]

    connection {
      type        = "ssh"
      user        = "vagrant"
      private_key = file("${path.module}/insecure_private_key")
      host        = self.network_adapter[0].ipv4_address
      port        = 22
    }
  }
}

output "master_ip" {
  value = virtualbox_vm.master.network_adapter[0].ipv4_address
}

output "node_ips" {
  value = [for i in virtualbox_vm.node : i.network_adapter[0].ipv4_address]
}
