
#!/bin/bash

# ==========================================
# TEKITIZY - Gestion des utilisateurs
# ==========================================

# Vérifier les droits administrateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : lancez avec sudo."
    exit 1
fi

echo "=========================================="
echo "       TEKITIZY - CREATION DES COMPTES"
echo "=========================================="

# Vérifier Python
if ! command -v python3 > /dev/null 2>&1; then
    echo "Erreur : Python 3 n'est pas installé."
    exit 1
fi

# Vérifier le fichier Python
if [ ! -f "scripts/tekitizy_manager.py" ]; then
    echo "Erreur : programme Python introuvable."
    exit 1
fi

# Lancer Python
python3 scripts/tekitizy_manager.py

# Vérifier le résultat
if [ $? -eq 0 ]; then
    echo "TEKITIZY : opération terminée."
else
    echo "Erreur pendant la gestion des utilisateurs."
    exit 1
fi
