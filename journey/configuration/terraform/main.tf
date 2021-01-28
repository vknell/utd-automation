provider "panos" {}

resource "panos_ethernet_interface" "untrust" {
  name                      = "ethernet1/1"
  comment                   = "untrust interface"
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = true
}

resource "panos_ethernet_interface" "web" {
  name        = "ethernet1/2"
  comment     = "web interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}

resource "panos_ethernet_interface" "db" {
  name        = "ethernet1/3"
  comment     = "database interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}