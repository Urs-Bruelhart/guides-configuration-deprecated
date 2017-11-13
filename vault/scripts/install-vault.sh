#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

VAULT_VERSION="${VERSION}"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL=${URL:-"https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"}

logger "Downloading vault ${VAULT_VERSION}"
curl --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL}

logger "Installing vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault
sudo chown ${USER}:${GROUP} /usr/local/bin/vault
logger "/usr/local/bin/vault --version: $(/usr/local/bin/vault --version)"

logger "Configuring vault ${VAULT_VERSION}"
sudo mkdir -pm 0755 /etc/vault.d
sudo mkdir -pm 0755 /opt/vault/data
sudo mkdir -pm 0755 /etc/ssl/vault
sudo chmod -R 0755 /opt/vault/*
sudo chmod -R 0755 /etc/ssl/vault/*

# Copy over all example Vault config files
sudo cp /tmp/vault/config/* /etc/vault.d/.

# Start Vault in -dev mode
echo 'FLAGS=-dev -dev-root-token-id=root' | sudo tee /etc/vault.d/vault.conf

sudo chown -R ${USER}:${GROUP} /etc/vault.d /opt/vault /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*

echo "export VAULT_ADDR=http://127.0.0.1:8200" | sudo tee /etc/profile.d/vault.sh
echo "export VAULT_TOKEN=root" | sudo tee -a /etc/profile.d/vault.sh

logger "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

logger "Complete"
