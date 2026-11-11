
import csv
import os
import unicodedata
import re

# Fonction pour nettoyer les noms des dossiers
def nettoyer(nom):
    nom = unicodedata.normalize("NFD", nom)
    nom = "".join(c for c in nom if unicodedata.category(c) != "Mn")

    nom = nom.strip()
    nom = re.sub(r"[\s-]+", "_", nom)
    nom = nom.replace("'", "")

    return nom


# Vérifier le fichier CSV
fichier_csv = "config/tekitizy_users.csv"

if not os.path.exists(fichier_csv):
    print("Erreur : fichier CSV introuvable.")
    exit(1)


# Créer les dossiers principaux
os.makedirs("/SERVICES/COMMUN", exist_ok=True)
os.makedirs("/PROJETS", exist_ok=True)
os.makedirs("/ARCHIVES", exist_ok=True)

# Lire les salariés
with open(fichier_csv, encoding="utf-8-sig", newline="") as fichier:
    lecteurs = csv.DictReader(fichier)

    for salarie in lecteurs:

        pole = salarie["Pole"].strip()
        sous_service = salarie["SousService"].strip()
        projets = salarie["Projet"].strip()

        # Créer le dossier du pôle
        if pole:
            nom_pole = nettoyer(pole)
            dossier_pole = "/SERVICES/" + nom_pole

            os.makedirs(dossier_pole, exist_ok=True)

            print("Dossier créé :", dossier_pole)

        # Créer le dossier du sous-service
        if pole and sous_service:
            nom_service = nettoyer(sous_service)
            dossier_service = dossier_pole + "/" + nom_service

            os.makedirs(dossier_service, exist_ok=True)

            print("Dossier créé :", dossier_service)

        # Créer les dossiers des projets
        if projets:
            for projet in projets.split(";"):
                nom_projet = nettoyer(projet.strip())

                if nom_projet:
                    dossier_projet = "/PROJETS/" + nom_projet

                    os.makedirs(dossier_projet, exist_ok=True)

                    print("Dossier créé :", dossier_projet)


print("Création des dossiers terminée.")
