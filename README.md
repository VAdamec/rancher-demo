# Demo platform for testing Rancher with Catle
- OSS based stack (deployed via Terraform)

## Components
- 2x docker for Catle
 - demo-rancher-minimal-server-region01-[oss_login]
 - demo-rancher-minimal-host-region0x-[oss_login]  (x=var.docker, as hosts can be easily scaled)

## Prerequisities
- OpenStack login/pass and key_pair
- Latest stable Docker

# Start instances for Rancher in OpenStack
* If you have Windows OS, some steps need to be done in different way (commands, paths, ...) to run docker container

```bash
## Clone repozitory:
[root@workstation ]# git clone https://github.com/VAdamec/rancher-demo

# Run Docker
[root@workstation ]$ docker build -t rancher-minimal .
[root@workstation ]$ cp ~/.ssh/<your_oss_ssh_key> terraform.pem
[root@workstation ]$ docker run -v `pwd`:/code -ti rancher-minimal /bin/bash

## Rename sample variables and add your credentials
[root@container /]$ cd /code
[root@container code]$ mv variables.sample variables.tf # setup your credentials to OpenStack
[root@container code]$ terraform plan # check OSS variable setup, should show you adding two new servers
[root@container code]$ terraform apply
[root@container code]$ terraform output  # to see IP addresses of instances
```


## Setup rancher and hosts via Ansible

```
[root@container code]$ ansible-playbook rancher-provision.yml
```

## Setup rancher manually
* Follow http://docs.rancher.com/rancher/v1.3/en/quick-start-guide/
 * this will lead you through installation

# Login to UI
- get IPADDRESS of demo-rancher-minimal-server-region01-[oss_login] and put it to browser http://IPADDRESS
 - you should be abble to see UI and after a few seconds also registered host(s)

# Examples
- wordpress - just frontend and database, exposed at IP address of http://IPADDRESS:8080

```bash
# You need Environment API key and URL exported, http://IPADDRESS/env/1a5/api/keys

export RANCHER_URL=http://<server_ip>/v2-beta/projects/1a5
export RANCHER_ACCESS_KEY=xxxxxxx
export RANCHER_SECRET_KEY=xxxxxxxxxxxxxxxxx

cd wordpress
rancher-compose up
#... some changes ...
rancher-compose up --force-upgrade
rancher-compose down
rancher-compose rm
```
