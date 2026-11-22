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
    acl

# Installation de Firefox
apt install -y firefox

# Installation de Google Chrome
echo "Installation de Google Chrome..."

wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt update
apt install -y ./chrome.deb
rm chrome.deb

# Installation de Visual Studio Code
echo "Installation de VS Code..."

wget -O code.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
apt update
apt install -y ./code.deb
rm code.deb

echo "=== INSTALLATION TERMINEE ==="
