
import csv
import unicodedata
import subprocess

# Fichiers du projet
FICHIER_CSV = "config/tekitizy_users.csv"
FICHIER_LOGINS = "config/tekitizy_logins.csv"


# Nettoyer les noms pour les logins et les groupes
def nettoyer(texte):
    texte = unicodedata.normalize("NFD", texte)
    texte = "".join(c for c in texte if unicodedata.category(c) != "Mn")
    texte = texte.lower()
    texte = "".join(c for c in texte if c in "abcdefghijklmnopqrstuvwxyz0123456789")
    return texte


# Charger les anciens identifiants
anciens = {}

try:
    with open(FICHIER_LOGINS, encoding="utf-8") as fichier:
        lecteur = csv.DictReader(fichier)

        for ligne in lecteur:
            anciens[ligne["Matricule"]] = ligne["Login"]

except FileNotFoundError:
    pass


# Lire les salariés
with open(FICHIER_CSV, encoding="utf-8-sig", newline="") as fichier:
    lecteurs = csv.DictReader(fichier)

    for salarie in lecteurs:

        matricule = salarie["Matricule"].strip()
        prenom = salarie["Prénom"].strip()
        nom = salarie["Nom"].strip()
        date = salarie["DateNaissance"].strip()

        pole = salarie["Pole"].strip()
        sous_service = salarie["SousService"].strip()
        projets = salarie["Projet"].strip()

        # Récupérer ou générer le login
        if matricule in anciens:
            login = anciens[matricule]

        else:
            login = nettoyer(prenom[0] + nom)
            login = login[:8]

            base = login[:6]
            compteur = 1

            while login in anciens.values():
                login = base + str(compteur).zfill(2)
                compteur += 1

            anciens[matricule] = login

        # Préparer les groupes
        groupes = ["personnel"]

        if pole:
            groupes.append(nettoyer(pole))

        if sous_service:
            groupes.append(nettoyer(sous_service))

        if projets:
            for projet in projets.split(";"):
                projet = nettoyer(projet.strip())

                if projet:
                    groupes.append(projet)

        # Supprimer les doublons de groupes
        groupes = list(dict.fromkeys(groupes))

        print("Traitement de :", prenom, nom)

        # Créer les groupes
        for groupe in groupes:
            resultat = subprocess.run(
                ["groupadd", "-f", groupe],
                capture_output=True,
                text=True
            )

            if resultat.returncode != 0:
                print("Erreur groupe :", groupe, resultat.stderr)
                continue

        # Vérifier si l'utilisateur existe
        resultat = subprocess.run(
            ["id", login],
            capture_output=True
        )

        if resultat.returncode != 0:

            # Créer l'utilisateur
            subprocess.run(
                ["useradd", "-m", "-s", "/bin/bash", login],
                check=True
            )

            # Définir le mot de passe initial JJMMAAAA
            jour, mois, annee = date.split("/")
            mot_de_passe = jour + mois + annee

            subprocess.run(
                ["chpasswd"],
                input=login + ":" + mot_de_passe + "\n",
                text=True,
                check=True
            )

            # Forcer le changement du mot de passe
            subprocess.run(
                ["chage", "-d", "0", login],
                check=True
            )

            print("Utilisateur créé :", login)

        else:
            print("Utilisateur déjà existant :", login)

        # Ajouter les groupes à l'utilisateur
        subprocess.run(
            ["usermod", "-aG", ",".join(groupes), login],
            check=True
        )

        print("Groupes :", ", ".join(groupes))
        print("-----------------------------")


# Enregistrer les identifiants
with open(FICHIER_LOGINS, "w", encoding="utf-8", newline="") as fichier:
    ecrivain = csv.writer(fichier)

    ecrivain.writerow(["Matricule", "Login"])

    for matricule, login in anciens.items():
        ecrivain.writerow([matricule, login])

print("Gestion des utilisateurs terminée.")
