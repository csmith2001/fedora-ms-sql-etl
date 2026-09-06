#!/usr/bin/env bash

if ! command -v pwsh >/dev/null 2>&1; then
    printf 'Powershell not installed...\n'
fi

printf 'PowerShell is installed...\n'
read -rp "You will need sudo access to continue. Do you wish to move forward? [Y/N]: " response

if [[ "$response" =~ ^[Yy]$ ]]; then
    if ! sudo dnf install -y powershell; then
        printf 'Installation failed.'
        exit 1
    fi
elif [[ "$response" =~ ^[Nn]$ ]]; then
    printf 'Installation cancelled!'
    exit 0
else
    printf 'Invalid response!'
    exit 1
fi

read -rp "PowerShell is installed, do you wish to move forward? [Y/N]: " continue

if [[ "$continue" =~ ^[Nn]$ ]]; then
    printf 'Operation cancelled.'
    exit 0
elif [[ ! "$continue" =~ ^[Yy]$ ]]; then
    printf 'Invalid response!'
    exit 1
fi

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo curl -o /etc/yum.repos.d/microsoft.repo \
https://packages.microsoft.com/config/rhel/9/prod.repo

sudo dnf clean all
sudo dnf makecache
