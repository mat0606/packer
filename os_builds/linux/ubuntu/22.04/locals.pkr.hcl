locals {
  os_family               = "Linux"
  os_flavour              = "Ubuntu"
  os_version              = "22.04"
  os_image                = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  build_by                = "Built by: HashiCorp Packer ${packer.version}"
  build_date              = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  manifest_date           = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path           = "${path.cwd}/manifests/"
  cloud_init              = templatefile("${abspath(path.root)}/data/config.pkrtpl.hcl", { build_username = var.build_username, build_password = var.build_password })
}