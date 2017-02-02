variable "docker" {
  default = 1
}

data "template_file" "docker" {
    template = "${file("bootstrapdocker.sh.tpl")}"
}

resource "openstack_compute_instance_v2" "server" {
  count = "1"
  name = "${format("demo-rancher-minimal-server-region%02d-${var.openstack_user_name}", count.index+1)}"
  image_name = "demo-centos7-gencloud20160906-image"
  availability_zone = "Temp"
  flavor_name = "demo-medium"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["allow_all"]
  region = "demo"
  network {
    name = "Infra"
  }
  config_drive = "true"

  user_data = "${data.template_file.docker.rendered}"
}

resource "openstack_compute_instance_v2" "hosts" {
  count = "${var.docker}"
  name = "${format("demo-rancher-minimal-host-region%02d-${var.openstack_user_name}", count.index+1)}"
  image_name = "demo-centos7-gencloud20160906-image"
  availability_zone = "Temp"
  flavor_name = "demo-medium"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["allow_all"]
  region = "demo"
  network {
    name = "Infra"
  }
  config_drive = "true"

  user_data = "${data.template_file.docker.rendered}"
}

output "server" {
  value = "${join(",", openstack_compute_instance_v2.server.*.access_ip_v4)}"
}

output "hosts" {
  value = "${join(",", openstack_compute_instance_v2.hosts.*.access_ip_v4)}"
}
