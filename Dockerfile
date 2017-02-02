FROM fedora:23
MAINTAINER "Vaclav Adamec <vaclav.adamec@suchy-zleb.cz>"

ENV TERRAFORM_VERSION=0.8.4
ENV TERRAFORM_SHA256SUM=297d35d0b4311445cd87ef032d3dec917bcc7a8b163ead28a4c45d966a2f75cc

RUN dnf install -y bash wget ansible unzip tar openssh-clients graphviz which; pip install docker-py

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1  | egrep -e '(OK|FAILED)$'; echo $?

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin; rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ENV RANCHER_VERSION=v0.12.2

ADD https://github.com/rancher/rancher-compose/releases/download/${RANCHER_VERSION}/rancher-compose-linux-amd64-${RANCHER_VERSION}.tar.gz ./
RUN tar -xzf rancher-compose-linux-amd64-${RANCHER_VERSION}.tar.gz; cp rancher-compose-${RANCHER_VERSION}/rancher-compose /bin/rancher-compose

WORKDIR /code
CMD ["/bin/bash"]
