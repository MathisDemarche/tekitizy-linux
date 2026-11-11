
#!/bin/bash

# ==========================================
# TEKITIZY - Installation des extensions VS Code
# ==========================================

# Vérifier que le script est lancé en administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez ce script avec sudo."
    exit 1
fi

# Vérifier qu'un utilisateur a été indiqué
if [ -z "$1" ]; then
    echo "Erreur : aucun utilisateur indiqué."
    echo "Utilisation : sudo bash install_extensions.sh LOGIN"
    exit 1
fi

LOGIN="$1"

# Récupérer le dossier personnel de l'utilisateur
HOME_DIR=$(getent passwd "$LOGIN" | cut -d: -f6)

if [ -z "$HOME_DIR" ]; then
    echo "Erreur : l'utilisateur $LOGIN n'existe pas."
    exit 1
fi

# Vérifier que VS Code est installé
if ! command -v code > /dev/null 2>&1; then
    echo "Erreur : VS Code n'est pas installé."
    exit 1
fi

echo "Installation des extensions pour $LOGIN..."

# Liste des extensions à installer
EXTENSIONS=(
    "ms-vscode.cpptools"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ritwickdey.liveserver"
    "ms-vscode.cmake-tools"
)

# Installer les extensions pour l'utilisateur
for extension in "${EXTENSIONS[@]}"
do
    echo "Installation de $extension..."

    if runuser -u "$LOGIN" -- env HOME="$HOME_DIR" code --install-extension "$extension"; then
        echo "$extension : OK"
    else
        echo "Attention : impossible d'installer $extension."
    fi
done

echo "Installation des extensions terminée pour $LOGIN."
