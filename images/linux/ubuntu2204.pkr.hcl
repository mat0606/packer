packer {
  required_plugins {
    nutanix = {
      version = ">= 0.8.1"
      source  = "github.com/nutanix-cloud-native/nutanix"
    }
  }
}

locals {
  managed_image_name = var.managed_image_name != "" ? var.managed_image_name : "${local.image_os}-${var.image_version}"
  image_os           = "ubuntu22.04"
  cloud_init         = templatefile("${abspath(path.root)}/data/config.pkrtpl.hcl", { build_username = var.build_username, build_password = var.build_password })
  os_image           = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

// Image output settings
variable "managed_image_name" {
  type    = string
  default = ""
}

variable "image_version" {
  type    = string
  default = "dev"
}

// Prism Central credentials

variable "nutanix_username" {
  type        = string
  description = "This is the username for the Prism Central instance. Required for provider"
  default     = env("NUTANIX_USERNAME")
}

variable "nutanix_password" {
  type        = string
  description = "This is the password for the Prism Central instance. Required for provider"
  sensitive   = true
  default     = env("NUTANIX_PASSWORD")
}

variable "nutanix_endpoint" {
  type        = string
  description = "This is the IP address or FQDN for the Prism Central instance. Required for provider"
  default     = env("NUTANIX_ENDPOINT")
}

variable "nutanix_port" {
  type        = number
  description = "This is the port for the Prism Central instance. Required for provider"
  default     = 9440
}

variable "nutanix_insecure" {
  type        = bool
  description = "This specifies whether to allow verify ssl certificates. Required for provider"
  default     = false
}

variable "nutanix_wait" {
  type        = number
  description = "This specifies the timeout on all resource operations in the provider in minutes. Required for provider"
  default     = 1
}

// Prism settings

variable "nutanix_cluster" {
  type        = string
  description = "This is the Prism Element cluster name. Required for building the image"
  default     = env("NUTANIX_CLUSTER_NAME")
}

variable "nutanix_subnet_uuid" {
  type        = string
  description = "This is the Prism Element subnet name or UUID. Use UUID if there are multiple subnets with the same name. Required for building the image"
  default     = env("NUTANIX_SUBNET_NAME")
}

// Virtual machine settings

variable "nutanix_vm_cpu" {
  type        = number
  description = "Number of virtual CPUs. Required for building the image"
  default     = 4
}

variable "nutanix_vm_memory_mb" {
  type        = number
  description = "Virtual machine memory. Required for building the image"
  default     = 16384
}

variable "nutanix_vm_boot_type" {
  type        = string
  description = "Virtual machine boot type. Required for building the image"
  default     = "uefi" # Options: legacy / uefi
}

variable "nutanix_vm_disk_size_gb" {
  type        = number
  description = "Virtual machine disk size (GB). Required for building the image"
  default     = 100
}

// Packer connection settings

variable "build_username" {
  type        = string
  description = "Packer username. Required by Packer for connecting to the guest OS"
  default     = "ubuntu"
}

variable "build_password" {
  type        = string
  description = "Packer password. Required by Packer for connecting to the guest OS"
  sensitive   = true
  default     = env("PACKER_BUILD_PASSWORD")
}

source "nutanix" "build_image" {

  // Prism Central Endpoint Settings and Credentials
  nutanix_username = var.nutanix_username
  nutanix_password = var.nutanix_password
  nutanix_endpoint = var.nutanix_endpoint
  nutanix_port     = var.nutanix_port
  nutanix_insecure = var.nutanix_insecure

  // Prism Element Cluster
  cluster_name = var.nutanix_cluster

  // Virtual Machine Settings
  cpu       = var.nutanix_vm_cpu
  os_type   = "Linux"
  memory_mb = var.nutanix_vm_memory_mb
  boot_type = var.nutanix_vm_boot_type

  vm_nics {
    subnet_uuid = var.nutanix_subnet_uuid
  }

  // Virtual Machine Connection
  ssh_username = var.build_username
  ssh_password = var.build_password

  // AHV Disk Image Creation
  force_deregister = true

  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "2m"
}

build {
  name = "bootstrap"

  source "nutanix.build_image" {
    image_name = "bootstrap-${local.managed_image_name}"
    user_data  = base64encode(local.cloud_init)

    vm_disks {
      image_type       = "DISK_IMAGE"
      source_image_uri = local.os_image
      disk_size_gb     = var.nutanix_vm_disk_size_gb
    }
  }

  provisioner "shell" {
    inline = [
      "cloud-init status --wait"
    ]
  }
}

build {
  name = "base"

  source "nutanix.build_image" {
    image_name = "base-${local.managed_image_name}"
    vm_disks {
      image_type        = "DISK_IMAGE"
      source_image_name = "bootstrap-${local.managed_image_name}"
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo -E apt-get update && sudo -E apt-get upgrade -y"
    ]
  }
}

build {
  name = "golden"

  source "nutanix.build_image" {
    image_name = "golden-${local.managed_image_name}"
    vm_disks {
      image_type        = "DISK_IMAGE"
      source_image_name = "base-${local.managed_image_name}"
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    inline = [
      "sudo sed -i \"/#\\$nrconf{restart} = 'i';/s/.*/\\$nrconf{restart} = 'a';/\" /etc/needrestart/needrestart.conf",
      "sudo -E apt-get install -yq sshpass net-tools python3-pip jq sssd-ad sssd-tools realmd adcli krb5-user openjdk-17-jdk nfs-common autofs git",
      "sudo systemctl enable iscsid"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    scripts = [
      "./scripts/shell/flexera/install-full-agent.sh",
      "./scripts/shell/kubernetes/install-kubectl.sh",
    ]
  }

  # provisioner "ansible" {
  #   playbook_file = "./scripts/ansible/playbook.yaml"
  #   galaxy_file   = "./scripts/ansible/requirements.yaml"
  #   extra_arguments = [
  #     "--extra-vars", "os_auth_pam_passwdqc_enable=false os_auth_pw_max_age=99999 os_ignore_users=[\"ubuntu\"] os_user_pw_ageing=false os_users_without_password_ageing=[\"ubuntu\"]"
  #   ]
  # }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo -E ua detach --assume-yes || true",
      "sudo -E rm -rf /var/log/ubuntu-advantage.log",
      "sudo -E truncate -s 0 /etc/machine-id",
      "sudo -E truncate -s 0 /var/lib/dbus/machine-id"
    ]
  }

}

build {
  name = "tradeshow"

  source "nutanix.build_image" {
    image_name = "packer-tradeshow-${local.managed_image_name}"
    user_data  = base64encode(local.cloud_init)

    vm_disks {
      image_type       = "DISK_IMAGE"
      source_image_uri = local.os_image
      disk_size_gb     = var.nutanix_vm_disk_size_gb
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo -E apt-get update && sudo -E apt-get upgrade -y",
      "sudo sed -i \"/#\\$nrconf{restart} = 'i';/s/.*/\\$nrconf{restart} = 'a';/\" /etc/needrestart/needrestart.conf",
      "sudo -E apt-get install -yq sshpass net-tools python3-pip jq sssd-ad sssd-tools realmd adcli krb5-user openjdk-17-jdk nfs-common autofs git",
      "sudo systemctl enable iscsid"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    scripts = [
      "./scripts/shell/flexera/install-full-agent.sh",
      "./scripts/shell/kubernetes/install-kubectl.sh",
    ]
  }

  # provisioner "ansible" {
  #   playbook_file = "./scripts/ansible/playbook.yaml"
  #   galaxy_file   = "./scripts/ansible/requirements.yaml"
  #   extra_arguments = [
  #     "--extra-vars", "os_auth_pam_passwdqc_enable=false os_auth_pw_max_age=99999 os_ignore_users=[\"ubuntu\"] os_user_pw_ageing=false os_users_without_password_ageing=[\"ubuntu\"]"
  #   ]
  # }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo -E ua detach --assume-yes || true",
      "sudo -E rm -rf /var/log/ubuntu-advantage.log",
      "sudo -E truncate -s 0 /etc/machine-id",
      "sudo -E truncate -s 0 /var/lib/dbus/machine-id"
    ]
  }

}

build {
  name = "gts24-ai"

  source "nutanix.build_image" {
    image_name = "packer-gts24-ai-${local.managed_image_name}"
    user_data  = base64encode(local.cloud_init)

    vm_disks {
      image_type       = "DISK_IMAGE"
      source_image_uri = local.os_image
      disk_size_gb     = var.nutanix_vm_disk_size_gb
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo -E apt-get update && sudo -E apt-get upgrade -y",
      "sudo sed -i \"/#\\$nrconf{restart} = 'i';/s/.*/\\$nrconf{restart} = 'a';/\" /etc/needrestart/needrestart.conf",
    ]
  }
/*
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    scripts = [
     "./scripts/shell/misc/install-common-pkgs.sh",
      "./scripts/shell/flexera/install-full-agent.sh",
      "./scripts/shell/kubernetes/install-kubectl.sh",
      "./scripts/shell/kubernetes/install-helm.sh",
      "./scripts/shell/nutanix/giab-pip-reqs.sh",
    ]
  }
*/
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo -E ua detach --assume-yes || true",
      "sudo -E rm -rf /var/log/ubuntu-advantage.log",
      "sudo -E truncate -s 0 /etc/machine-id",
      "sudo -E truncate -s 0 /var/lib/dbus/machine-id"
    ]
  }

}

build {
  name = "gts24-migrate"

  source "nutanix.build_image" {
    image_name = "packer-gts24-migrate-${local.managed_image_name}"
    user_data  = base64encode(local.cloud_init)

    vm_disks {
      image_type       = "DISK_IMAGE"
      source_image_uri = local.os_image
      disk_size_gb     = var.nutanix_vm_disk_size_gb
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo -E apt-get update && sudo -E apt-get upgrade -y",
      "sudo sed -i \"/#\\$nrconf{restart} = 'i';/s/.*/\\$nrconf{restart} = 'a';/\" /etc/needrestart/needrestart.conf",
      "sudo -E apt-get install -yq sshpass net-tools python3-pip jq sssd-ad sssd-tools realmd adcli krb5-user openjdk-17-jdk nfs-common autofs git",
      "sudo systemctl enable iscsid"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    scripts = [
      "./scripts/shell/flexera/install-full-agent.sh",
      "./scripts/shell/nutanix/migrate-nginx.sh",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo -E ua detach --assume-yes || true",
      "sudo -E rm -rf /var/log/ubuntu-advantage.log",
      "sudo -E truncate -s 0 /etc/machine-id",
      "sudo -E truncate -s 0 /var/lib/dbus/machine-id"
    ]
  }

}