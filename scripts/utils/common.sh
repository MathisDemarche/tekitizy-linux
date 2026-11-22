#!/bin/bash

# Fonctions communes TEKITIZY

nettoyer_groupe() {
    printf '%s\n' "$1" |
        iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        tr -cd 'a-z0-9_'
}

nettoyer_dossier() {
    printf '%s\n' "$1" |
        iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null |
        tr '[:lower:]' '[:upper:]' |
        sed "s/[ -]/_/g; s/'//g" |
        tr -cd 'A-Z0-9_'
}

nettoyer_login() {
    printf '%s\n' "$1" |
        iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        tr -cd 'a-z0-9'
}

creer_groupe() {
    local groupe
    groupe=$(nettoyer_groupe "$1")

    [[ -z "$groupe" ]] && return 0

    if ! getent group "$groupe" >/dev/null; then
        groupadd "$groupe" || return 1
        echo "Groupe créé : $groupe"
    fi
}

# Retire les espaces au début et à la fin d'une chaîne.
retirer_espaces() {
    local valeur="$1"
    valeur="${valeur#"${valeur%%[![:space:]]*}"}"
    valeur="${valeur%"${valeur##*[![:space:]]}"}"
    printf '%s' "$valeur"
}
