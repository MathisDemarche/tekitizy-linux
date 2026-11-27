
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
    local home user_data_dir

    home=$(getent passwd "$login" | cut -d: -f6)

    if [[ -z "$home" ]]; then
        echo "Utilisateur introuvable : $login"
        return 1
    fi

    if ! command -v code >/dev/null 2>&1; then
        echo "VS Code non installé."
        return 1
    fi

    # La CLI doit utiliser les paramètres du compte cible pendant l'installation.
    mkdir -p "$COMMON" "$home/.config/Code/User"
    user_data_dir="$home/.config/Code"
    printf '{\n    "extensions.verifySignature": false\n}\n' \
        > "$user_data_dir/User/settings.json"

    for ext in "${EXTENSIONS[@]}"; do
        if ! code --no-sandbox \
                  --user-data-dir "$user_data_dir" \
                  --extensions-dir "$COMMON" \
                  --install-extension "$ext" --force; then
            chown -R "$login:$login" "$user_data_dir"
            return 1
        fi
    done

    chown -R "$login:$login" "$user_data_dir"

    # Utiliser les extensions communes
    mkdir -p "$home/.vscode"

    ln -sfn "$COMMON" "$home/.vscode/extensions"

    echo "Extensions configurées pour $login."
}

