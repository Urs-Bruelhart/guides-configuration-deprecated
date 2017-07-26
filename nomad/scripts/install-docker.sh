#!/bin/bash
set -x

YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

logger "Running"

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

if [[ ! -z ${YUM} ]]; then
  echo "Installing Docker with RHEL Workaround"
  sudo yum -y install ftp://fr2.rpmfind.net/linux/centos/7.3.1611/extras/x86_64/Packages/container-selinux-2.12-2.gite7096ce.el7.noarch.rpm
  curl -sSL https://get.docker.com/ | sed -e '365s/redhat/centos/' | sed -e '376s/redhat/centos/' | sudo sh
elif [[ ! -z ${APT_GET} ]]; then
  echo "Installing Docker"
  curl -sSL https://get.docker.com/ | sudo sh
else
  logger "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

sudo sh -c "echo \"DOCKER_OPTS='--dns 127.0.0.1 --dns 8.8.8.8 --dns-search service.consul'\" >> /etc/default/docker"

logger "Complete"