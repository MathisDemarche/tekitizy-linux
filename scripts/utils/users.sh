#!/bin/bash

# Gestion des comptes et des groupes TEKITIZY

trouver_login() {
    local matricule="$1"

    getent passwd | awk -F: -v identifiant="TEKITIZY:$matricule" \
        '$5 == identifiant { print $1; exit }'
}

generer_login() {
    local prenom="$1"
    local nom="$2"
    local base login compteur

    base=$(nettoyer_login "${prenom:0:1}${nom}")
    base="${base:0:8}"

    if [[ -z "$base" ]]; then
        echo "Impossible de générer un login pour $prenom $nom." >&2
        return 1
    fi

    login="$base"
    compteur=1

    while id "$login" >/dev/null 2>&1; do
        if (( compteur > 99 )); then
            echo "Trop de doublons pour le login $base." >&2
            return 1
        fi

        login="${base:0:6}$(printf '%02d' "$compteur")"
        ((compteur++))
    done

    printf '%s\n' "$login"
}

creer_utilisateur() {
    local matricule="$1"
    local prenom="$2"
    local nom="$3"
    local date_naissance="$4"
    local login password

    # Un compte déjà associé au matricule conserve son login.
    login=$(trouver_login "$matricule")

    if [[ -n "$login" ]]; then
        echo "Utilisateur déjà connu : $login" >&2
        printf '%s\n' "$login"
        return 0
    fi

    login=$(generer_login "$prenom" "$nom") || return 1
    password=$(printf '%s' "$date_naissance" | tr -cd '0-9')

    if [[ ! "$password" =~ ^[0-9]{8}$ ]]; then
        echo "Date de naissance invalide pour $prenom $nom." >&2
        return 1
    fi

    useradd -m -c "TEKITIZY:$matricule" "$login" || return 1

    if ! printf '%s:%s\n' "$login" "$password" | chpasswd; then
        userdel -r "$login" >/dev/null 2>&1
        return 1
    fi

    chage -d 0 "$login" || return 1

    echo "Utilisateur créé : $login" >&2
    printf '%s\n' "$login"
}

ajouter_au_groupe() {
    local login="$1"
    local groupe
    groupe=$(nettoyer_groupe "$2")

    [[ -z "$groupe" ]] && return 0

    creer_groupe "$groupe" || return 1
    usermod -aG "$groupe" "$login" || return 1
}
