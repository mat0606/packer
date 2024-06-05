build {
    name = "bootstrap"

    source "nutanix.ubuntu-server" {
        image_name  = "bootstrap-${source.name}-${local.os_version}"
        user_data   = base64encode(local.cloud_init)
        
        vm_disks {
            image_type        = "DISK_IMAGE"
            source_image_uri = local.os_image
            disk_size_gb      = 40
        }
    }

    provisioner "shell" {
        inline = [
            "cloud-init status --wait"
        ]
    }

    post-processor "manifest" {
        output     = "${local.manifest_path}${build.name}_manifest.json"
        strip_path = true
        strip_time = true

        custom_data = {
            build_by          = local.build_by
            build_username    = var.build_username
            build_date        = local.build_date
            build_name        = "${build.name}-${source.name}-${local.os_version}"
        }
    }
}

build {
    name = "base"

    source "nutanix.ubuntu-server" {
        image_name            = "base-${source.name}-${local.os_version}"
        vm_disks {
            image_type        = "DISK_IMAGE"
            source_image_name = "bootstrap-${source.name}-${local.os_version}"
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

    post-processor "manifest" {
        output     = "${local.manifest_path}${build.name}_manifest.json"
        strip_path = false
        strip_time = false

        custom_data = {
            build_by          = local.build_by
            build_username    = var.build_username
            build_date        = local.build_date
            build_name        = "${build.name}-${source.name}-${local.os_version}"
        }
    }
}

build {
    name = "golden"

    source "nutanix.ubuntu-server" {
        image_name            = "golden-${source.name}-${local.os_version}"
        vm_disks {
            image_type        = "DISK_IMAGE"
            source_image_name = "base-${source.name}-${local.os_version}"
      }
    }

    provisioner "shell" {
        environment_vars = [
            "DEBIAN_FRONTEND=noninteractive"
        ]
        inline = [
            "sudo -E apt-get install -yq sssd-ad sssd-tools realmd adcli krb5-user sshpass"
        ]
    }

    # provisioner "ansible" {
    #     playbook_file    = "./ansible/playbook.yaml"
    #     galaxy_file      = "./ansible/requirements.yaml"
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


    post-processor "manifest" {
        output     = "${local.manifest_path}${build.name}_manifest.json"
        strip_path = true
        strip_time = false

        custom_data = {
            build_by          = local.build_by
            build_username    = var.build_username
            build_date        = local.build_date
            build_name        = "${build.name}-${source.name}-${local.os_version}"
        }
    }
}