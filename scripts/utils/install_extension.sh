
#!/bin/bash

# ==========================================
# TEKITIZY - Extensions VS Code
# ==========================================

COMMON="/opt/tekitizy/vscode/extensions"

EXTENSIONS=(
    "ms-vscode.cpptools"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ritwickdey.liveserver"
    "ms-vscode.cmake-tools"
)

installextensions() {
    local login="$1"
    local home

    home=$(getent passwd "$login" | cut -d: -f6)

    if [[ -z "$home" ]]; then
        echo "Utilisateur introuvable : $login"
        return 1
    fi

    if ! command -v code >/dev/null 2>&1; then
        echo "VS Code non installé."
        return 1
    fi

    # Installer les extensions une seule fois
    mkdir -p "$COMMON"

    for ext in "${EXTENSIONS[@]}"; do
        code --extensions-dir "$COMMON" \
             --install-extension "$ext" --force
    done

    # Configurer l'utilisateur
    mkdir -p "$home/.config/Code/User"

    echo '{
    "extensions.verifySignature": false
}' > "$home/.config/Code/User/settings.json"

    chown -R "$login:$login" "$home/.config/Code"

    # Utiliser les extensions communes
    mkdir -p "$home/.vscode"

    ln -sfn "$COMMON" "$home/.vscode/extensions"

    echo "Extensions configurées pour $login."
}
