
#!/bin/bash

# Vérifier les droits administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

echo "=== TEKITIZY : CREATION DES DOSSIERS ==="

# Lancer le programme Python
python3 scripts/create_directories.py

if [ $? -eq 0 ]; then
    echo "Création terminée."
else
    echo "Erreur lors de la création des dossiers."
    exit 1
fi
