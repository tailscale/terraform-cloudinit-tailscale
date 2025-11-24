data "digitalocean_image" "ubuntu" {
  slug = "ubuntu-25-04-x64"
}

data "digitalocean_image" "centos" {
  slug = "centos-stream-9-x64"
}

module "ubuntu-tailscale-client" {
  source         = "../../"
  auth_key       = var.tailscale_auth_key
  enable_ssh     = true
  hostname       = "example-client"
  advertise_tags = ["tag:example"]
  base64_encode  = false
}

resource "digitalocean_droplet" "ubuntu" {
  #checkov:skip=CKV_DIO_2:SSH key is provided via variable
  image     = data.digitalocean_image.ubuntu.id
  name      = "lbr-ubuntu-example"
  region    = "sfo2"
  size      = "s-1vcpu-1gb"
  ssh_keys  = var.ssh_key_ids
  user_data = module.ubuntu-tailscale-client.rendered
}

resource "digitalocean_droplet" "centos" {
  #checkov:skip=CKV_DIO_2:SSH key is provided via variable
  image     = data.digitalocean_image.centos.id
  name      = "lbr-centos-example"
  region    = "sfo2"
  size      = "s-1vcpu-1gb"
  ssh_keys  = var.ssh_key_ids
  user_data = module.ubuntu-tailscale-client.rendered
}
