#!/bin/bash

# Gestion des dossiers personnels et partagés TEKITIZY

configurer_partage() {
    local chemin="$1"
    local groupe
    groupe=$(nettoyer_groupe "$2")

    [[ -z "$groupe" ]] && return 0

    creer_groupe "$groupe" || return 1
    mkdir -p "$chemin" || return 1
    chown "root:$groupe" "$chemin" || return 1
    chmod 2770 "$chemin" || return 1

    # ACL par défaut pour permettre la collaboration dans le groupe.
    setfacl -m 'u::rwx,g::rwx,m::rwx,o::---,d:u::rwx,d:g::rwx,d:m::rwx,d:o::---' "$chemin" || return 1
}

creer_lien() {
    local source="$1"
    local destination="$2"

    if [[ ! -e "$destination" && ! -L "$destination" ]]; then
        ln -s "$source" "$destination" || return 1
    fi
}

initialiser_dossiers() {
    creer_groupe personnel || return 1

    mkdir -p /SERVICES /PROJETS /ARCHIVES || return 1
    chmod 755 /SERVICES /PROJETS || return 1

    configurer_partage /SERVICES/COMMUN personnel || return 1

    chown root:root /ARCHIVES || return 1
    chmod 700 /ARCHIVES || return 1
}

creer_dossiers_utilisateur() {
    local login="$1"
    local pole="$2"
    local sous_service="$3"
    local projets="$4"

    local home="/home/$login"
    local groupe_principal
    local dossier_pole dossier_sous_service
    local projet dossier_projet
    local -a liste_projets

    groupe_principal=$(id -gn "$login") || return 1

    mkdir -p "$home" \
        "$home/Documents" \
        "$home/Projets" \
        "$home/Workspace" \
        "$home/Téléchargements" \
        "$home/Partage" || return 1

    chown "$login:$groupe_principal" "$home" \
        "$home/Documents" \
        "$home/Projets" \
        "$home/Workspace" \
        "$home/Téléchargements" \
        "$home/Partage" || return 1

    chmod 700 "$home" || return 1

    # Pôle
    dossier_pole=$(nettoyer_dossier "$pole")
    if [[ -n "$pole" ]]; then
        configurer_partage "/SERVICES/$dossier_pole" "$pole" || return 1
        creer_lien "/SERVICES/$dossier_pole" "$home/Partage/$dossier_pole" || return 1
    fi

    # Sous-service
    dossier_sous_service=$(nettoyer_dossier "$sous_service")
    if [[ -n "$pole" && -n "$sous_service" ]]; then
        configurer_partage "/SERVICES/$dossier_pole/$dossier_sous_service" "$sous_service" || return 1
        creer_lien "/SERVICES/$dossier_pole/$dossier_sous_service" "$home/Partage/$dossier_sous_service" || return 1
    fi

    # Projets
    IFS=';' read -r -a liste_projets <<< "$projets"

    for projet in "${liste_projets[@]}"; do
        projet=$(retirer_espaces "$projet")
        [[ -z "$projet" ]] && continue

        dossier_projet=$(nettoyer_dossier "$projet")
        [[ -z "$dossier_projet" ]] && continue

        configurer_partage "/PROJETS/$dossier_projet" "$projet" || return 1
        creer_lien "/PROJETS/$dossier_projet" "$home/Projets/$dossier_projet" || return 1
    done

    echo "Dossiers configurés : $login"
}
