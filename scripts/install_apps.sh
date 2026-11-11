#!/bin/bash

# Vérifier les droits administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

echo "=== tekitizy LINUX : INSTALLATION ==="

# Mise à jour
apt update

# Installation des logiciels classiques
echo "Installation des outils de développement..."

apt install -y \
    git \
    build-essential \
    gdb \
    make \
    python3 \
    python3-pip \
    python3-venv \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    libreoffice-l10n-fr \
    libreoffice-help-fr \
    wget \
    gpg \
    ca-certificates

# Installation de Visual Studio Code
echo "Installation de VS Code..."

mkdir -p /etc/apt/keyrings

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \ | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg

echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64
Signed-By: /etc/apt/keyrings/microsoft.gpg" \
    > /etc/apt/sources.list.d/vscode.sources

apt update
apt install -y code

echo "=== INSTALLATION TERMINEE ==="
