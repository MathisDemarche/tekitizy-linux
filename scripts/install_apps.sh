#!/bin/bash

# Vérifier les droits administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

echo "=== tekitizy LINUX : INSTALLATION ==="

# Mise à jour
apt update

ARCHITECTURE=$(dpkg --print-architecture)
case "$ARCHITECTURE" in
    amd64) VSCODE_ARCH="x64" ;;
    arm64) VSCODE_ARCH="arm64" ;;
    *)
        echo "Erreur : architecture non prise en charge : $ARCHITECTURE"
        exit 1
        ;;
esac

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
if apt-cache show firefox >/dev/null 2>&1; then
    apt install -y firefox
elif apt-cache show firefox-esr >/dev/null 2>&1; then
    apt install -y firefox-esr
else
    echo "Erreur : aucun paquet Firefox disponible."
    exit 1
fi

# Installation de Chromium
echo "Installation de Chromium..."

if apt-cache show chromium >/dev/null 2>&1; then
    apt install -y chromium
elif apt-cache show chromium-browser >/dev/null 2>&1; then
    apt install -y chromium-browser
else
    echo "Erreur : aucun paquet Chromium disponible."
    exit 1
fi

# Installation de Visual Studio Code
echo "Installation de VS Code..."

if ! wget --tries=3 --timeout=30 -O code.deb \
    "https://update.code.visualstudio.com/latest/linux-deb-$VSCODE_ARCH/stable"; then
    echo "Erreur : téléchargement de VS Code impossible."
    rm -f code.deb
    exit 1
fi

apt update
if ! apt install -y ./code.deb; then
    rm -f code.deb
    exit 1
fi
rm -f code.deb

echo "=== INSTALLATION TERMINEE ==="
