
#!/bin/bash

# ==========================================
# TEKITIZY - INSTALLATION AUTOMATIQUE
# ==========================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

# Récupération du dossier du dépôt Git
DOSSIER="$(cd "$(dirname "$0")" && pwd)"

echo "================================"
echo "     INSTALLATION TEKITIZY"
echo "================================"

cd "$DOSSIER"

# 1. Vérification des fichiers
echo "[1/7] Vérification du projet..."

if [ ! -f "config/tekitizy_users.csv" ]; then
    echo "Erreur : fichier CSV introuvable."
    exit 1
fi

if [ ! -f "scripts/tekitizy_manager.py" ]; then
    echo "Erreur : gestionnaire Python introuvable."
    exit 1
fi

# 2. Installation des dépendances
echo "[2/7] Installation des dépendances..."

apt update
apt install -y git python3 python3-pip python3-venv

# 3. Installation des applications
echo "[3/7] Installation des applications..."

bash scripts/install_apps.sh

# 4. Création des utilisateurs
echo "[4/7] Création des utilisateurs..."

bash scripts/create_users.sh

# 5. Création des dossiers
echo "[5/7] Création des dossiers..."

bash scripts/create_directories.sh

# 6. Configuration des permissions
echo "[6/7] Configuration des permissions..."

bash scripts/set_permissions.sh

# Configuration de l'umask
echo "umask 0002" > /etc/profile.d/tekitizy.sh
chmod 644 /etc/profile.d/tekitizy.sh

# 7. Installation du service systemd
echo "[7/7] Configuration du démarrage automatique..."

cp services/tekitizy.service /etc/systemd/system/tekitizy.service

systemctl daemon-reload
systemctl enable tekitizy.service

echo "================================"
echo " INSTALLATION TEKITIZY TERMINEE"
echo "================================"
echo "Dossier : $DOSSIER"
echo "Service : tekitizy.service"
echo "Démarrage automatique activé."
