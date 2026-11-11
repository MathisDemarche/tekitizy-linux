#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez ce script avec sudo."
    exit 1
fi

echo "=== TEKITIZY : CONFIGURATION DES PERMISSIONS ==="

if [ ! -f "scripts/set_permissions.py" ]; then
    echo "Erreur : fichier Python introuvable."
    exit 1
fi

python3 scripts/set_permissions.py

if [ $? -eq 0 ]; then
    echo "TEKITIZY : permissions configurées."
else
    echo "Erreur pendant la configuration des permissions."
    exit 1
fi
