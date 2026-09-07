#!/usr/bin/env bash
# *********************************************************************************************
# === GLOBALS ===
MICROSOFT_REPO="https://packages.microsoft.com/config/rhel/9/prod.repo"
YUM_REPO="/etc/yum.repos.d/microsoft.repo"
MICROSOFT_SIGNING_KEY=$(
    curl -fsSL "$MICROSOFT_REPO" |
    awk -F= '/^gpgkey=/{print $2}'
)
# Make Globals Read-Only
readonly \
    MICROSOFT_SIGNING_KEY \
    YUM_REPO \
    MICROSOFT_REPO
# *********************************************************************************************
# === MAIN ===
# Add Microsoft Signing Key
echo "Adding Microsoft repository..."
sudo rpm --import "$MICROSOFT_SIGNING_KEY"
sudo curl -fsSL -o "$YUM_REPO" "$MICROSOFT_REPO"
sudo dnf clean all
sudo dnf makecache
# --
# Install PowerShell
echo "Installing PowerShell..."
sudo dnf install -y powershell
pwsh --version
