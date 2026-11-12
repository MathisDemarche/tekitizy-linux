
#!/bin/bash

# ==========================================
# TEKITIZY - INSTALLATION AUTOMATIQUE
# ==========================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

COULEUR_DATE='\033[36m'
COULEUR_ETAPE='\033[32m'
COULEUR_RESET='\033[0m'

afficher_etape() {
    printf "${COULEUR_DATE}[%s]${COULEUR_RESET} ${COULEUR_ETAPE}%s${COULEUR_RESET}\n" \
        "$(date '+%d/%m/%Y %H:%M:%S')" "$1"
}

# Récupération du dossier du dépôt Git
DOSSIER="$(cd "$(dirname "$0")" && pwd)"

echo "================================"
echo "     INSTALLATION TEKITIZY"
echo "================================"

cd "$DOSSIER"

# 1. Vérification des fichiers
afficher_etape "[1/7] Vérification du projet..."

if [ ! -f "config/tekitizy_users.csv" ]; then
    echo "Erreur : fichier CSV introuvable."
    exit 1
fi

if [ ! -f "scripts/tekitizy_manager.py" ]; then
    echo "Erreur : gestionnaire Python introuvable."
    exit 1
fi

# 2. Installation des dépendances
afficher_etape "[2/7] Installation des dépendances..."

apt update
apt install -y git python3 python3-pip python3-venv

# 3. Installation des applications
afficher_etape "[3/7] Installation des applications..."

bash scripts/install_apps.sh

# 4. Création des utilisateurs
afficher_etape "[4/7] Création des utilisateurs..."

bash scripts/create_users.sh

# 5. Création des dossiers
afficher_etape "[5/7] Création des dossiers..."

bash scripts/create_directories.sh

# 6. Configuration des permissions
afficher_etape "[6/7] Configuration des permissions..."

bash scripts/set_permissions.sh

# Configuration de l'umask
echo "umask 0002" > /etc/profile.d/tekitizy.sh
chmod 644 /etc/profile.d/tekitizy.sh

# 7. Installation du service systemd
afficher_etape "[7/7] Configuration du démarrage automatique..."

cp services/tekitizy.service /etc/systemd/system/tekitizy.service

systemctl daemon-reload
systemctl enable tekitizy.service

echo "================================"
echo " INSTALLATION TEKITIZY TERMINEE"
echo "================================"
echo "Dossier : $DOSSIER"
echo "Service : tekitizy.service"
echo "Démarrage automatique activé."
