#!/bin/bash

# ==========================================
# TEKITIZY - Installation des comptes et dossiers
# ==========================================

afficher_erreur() {
    printf '\033[31m%s\033[0m\n' "$*" >&2
}

# Charger les fonctions séparées.
source ./scripts/utils/common.sh
source ./scripts/utils/users.sh
source ./scripts/utils/directories.sh
source ./scripts/utils/install_extension.sh

if [[ ! -f ./config/tekitizy_users.csv ]]; then
    afficher_erreur "Erreur : fichier CSV introuvable : ./config/tekitizy_users.csv"
    exit 1
fi

# Vérifications
if [[ "$EUID" -ne 0 ]]; then
    afficher_erreur "Erreur : lancez ce script avec sudo."
    exit 1
fi


traiter_salarie() {
    local matricule="$1"
    local prenom="$2"
    local nom="$3"
    local date_naissance="$4"
    local pole="$5"
    local sous_service="$6"
    local projets="$7"

    local login projet
    local -a liste_projets

    echo
    echo "------------------------------------------"
    echo "Traitement : $prenom $nom ($matricule)"

    login=$(creer_utilisateur "$matricule" "$prenom" "$nom" "$date_naissance") || return 1

    ajouter_aux_groupes "$login" "$pole" "$sous_service" "$projets" || return 1
    supprimer_anciens_liens_projets "$login" "$projets" || return 1
    creer_dossiers_utilisateur "$login" "$pole" "$sous_service" "$projets" || return 1
    installextensions "$login" || return 1

    echo "Identifiant : $login"


    echo "Traitement terminé."
}

lecture_csv() {
    local matricule prenom nom date_naissance
    local pole sous_service poste projets reste
    local erreur=0

    # Les champs utilisés sont dans les 8 premières colonnes.
    # Le reste récupère les colonnes supplémentaires du CSV.
    while IFS=',' read -r matricule prenom nom date_naissance pole sous_service poste projets reste; do
        matricule="${matricule#$'\xef\xbb\xbf'}"
        matricule="${matricule%$'\r'}"

        [[ -z "$matricule" || "$matricule" == "Matricule" ]] && continue

        traiter_salarie \
            "$matricule" "$prenom" "$nom" "$date_naissance" "$pole" "$sous_service" "$projets" || {
                afficher_erreur "Erreur de traitement : $prenom $nom"
                erreur=1
            }
    done < ./config/tekitizy_users.csv

    return "$erreur"
}

# Programme principal
echo "=========================================="
echo "       TEKITIZY - GESTION UTILISATEURS"
echo "=========================================="

initialiser_dossiers || {
    afficher_erreur "Erreur lors de l'initialisation des dossiers."
    exit 1
}

lecture_csv || {
    afficher_erreur "Le traitement est terminé avec des erreurs."
    exit 1
}

echo
echo "=========================================="
echo "       TRAITEMENT TERMINÉ"
echo "=========================================="
