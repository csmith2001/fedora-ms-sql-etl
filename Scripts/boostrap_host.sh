#!/usr/bin/env bash

# Echo sudo requirements
read -rp "You will need sudo access to continue. Do you wish to move forward? [Y/N]: " response
# --
# If response is not yes, cancel install
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled!"
    exit 0
fi
# --
# If powershell returns command path, echo version
if command -v pwsh >/dev/null 2>&1; then
    echo "Powershell is already installed..."
    pwsh --version
    exit 0
fi