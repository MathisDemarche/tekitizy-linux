
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

    # Installer les extensions une seule fois
    mkdir -p "$COMMON"
    user_data_dir=$(mktemp -d "${TMPDIR:-/tmp}/tekitizy-vscode.XXXXXX") || return 1

    for ext in "${EXTENSIONS[@]}"; do
        if ! code --no-sandbox \
                  --user-data-dir "$user_data_dir" \
                  --extensions-dir "$COMMON" \
                  --install-extension "$ext" --force; then
            rm -rf -- "$user_data_dir"
            return 1
        fi
    done

    rm -rf -- "$user_data_dir" || return 1

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

