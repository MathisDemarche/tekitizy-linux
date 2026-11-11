
#!/bin/bash

# Vérifier les droits administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

echo "=== TEKITIZY : GESTION DES UTILISATEURS ==="

# Vérifier Python
if ! command -v python3 > /dev/null 2>&1; then
    echo "Erreur : Python 3 n'est pas installé."
    exit 1
fi

# Lancer le programme Python
python3 scripts/tekitizy_manager.py

# Vérifier si le programme a fonctionné
if [ $? -eq 0 ]; then
    echo "Gestion des identifiants terminée."
else
    echo "Erreur lors de l'exécution du programme Python."
    exit 1
fi
