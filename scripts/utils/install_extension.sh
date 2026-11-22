
#!/bin/bash

# ==========================================
# TEKITIZY - Installation des extensions VS Code
# ==========================================

installextensions() {
    local login="$1"
    local home_dir

    # Récupérer le dossier personnel de l'utilisateur
    home_dir=$(getent passwd "$login" | cut -d: -f6)

    if [ -z "$home_dir" ]; then
        echo "Erreur : l'utilisateur $login n'existe pas."
        return 1
    fi

    mkdir -p "$home_dir/.vscode/extensions" "$home_dir/.config/Code"
    chown -R "$login:$login" "$home_dir/.vscode" "$home_dir/.config/Code"

    # Vérifier que VS Code est installé
    if ! command -v code > /dev/null 2>&1; then
        echo "Erreur : VS Code n'est pas installé."
        return 1
    fi

    echo "Installation des extensions pour $login..."

    # Liste des extensions à installer
    local extensions=(
        "ms-vscode.cpptools"
        "ms-python.python"
        "ms-python.vscode-pylance"
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "ritwickdey.liveserver"
        "ms-vscode.cmake-tools"
    )

    # Installer les extensions pour l'utilisateur
    for extension in "${extensions[@]}"; do
        echo "Installation de $extension..."
        if sudo -u "$login" env HOME="$home_dir" \
            code --verbose --install-extension "$extension" --force; then
            echo "$extension : OK"
        else
            echo "Attention : impossible d'installer $extension."
        fi
    done

    echo "Installation des extensions terminée pour $login."
}
