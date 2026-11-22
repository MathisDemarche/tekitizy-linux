
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

# Lecture de la configuration JSON
CONFIG_JSON="config/config.json"

if [ ! -f "$CONFIG_JSON" ]; then
    echo "Erreur : configuration JSON introuvable : $CONFIG_JSON"
    exit 1
fi

config_valeur() {
    awk -F'"' -v cle="$1" '$2 == cle { print $4; exit }' "$CONFIG_JSON"
}

FICHIER_CSV=$(config_valeur users_csv)
SCRIPT_INSTALL_APPS=$(config_valeur install_apps)
SCRIPT_TEKITIZY=$(config_valeur tekitizy)
DOSSIER_UTILS=$(config_valeur utils_directory)
SERVICE_SYSTEMD=$(config_valeur systemd_service)
NOM_SERVICE=$(config_valeur service_name)

# 1. Vérification des fichiers
afficher_etape "[1/4] Vérification du projet..."

for FICHIER in \
    "$FICHIER_CSV" \
    "$SCRIPT_INSTALL_APPS" \
    "$SCRIPT_TEKITIZY" \
    "$DOSSIER_UTILS/common.sh" \
    "$DOSSIER_UTILS/users.sh" \
    "$DOSSIER_UTILS/directories.sh" \
    "$DOSSIER_UTILS/install_extension.sh" \
    "$SERVICE_SYSTEMD"; do
    if [ ! -f "$FICHIER" ]; then
        echo "Erreur : fichier introuvable : $FICHIER"
        exit 1
    fi
done

# 2. Installation des applications
afficher_etape "[2/4] Installation des applications..."

bash "$SCRIPT_INSTALL_APPS"

# 3. Création des utilisateurs et dossiers
afficher_etape "[3/4] Création des utilisateurs et dossiers..."

bash "$SCRIPT_TEKITIZY"

# Configuration de l'umask
echo "umask 0002" > /etc/profile.d/tekitizy.sh
chmod 644 /etc/profile.d/tekitizy.sh

# 4. Installation du service systemd
afficher_etape "[4/4] Configuration du démarrage automatique..."

sed "s|__DOSSIER__|$DOSSIER|g" "$SERVICE_SYSTEMD" \
    > "/etc/systemd/system/$NOM_SERVICE"

systemctl daemon-reload
systemctl enable "$NOM_SERVICE"

echo "================================"
echo " INSTALLATION TEKITIZY TERMINEE"
echo "================================"