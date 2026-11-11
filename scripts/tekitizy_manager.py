
import csv
import unicodedata

# Ouvrir le fichier CSV
with open("config/tekitizy_users.csv", encoding="utf-8-sig") as fichier:
    lecteurs = csv.DictReader(fichier)

    # Lire les anciens identifiants
    anciens = {}

    try:
        with open("config/tekitizy_logins.csv", encoding="utf-8") as fichier_logins:
            for ligne in csv.DictReader(fichier_logins):
                anciens[ligne["Matricule"]] = ligne["Login"]
    except FileNotFoundError:
        pass

    # Préparer le nouveau fichier
    with open("config/tekitizy_logins.csv", "w", newline="", encoding="utf-8") as sortie:
        ecrivain = csv.writer(sortie)
        ecrivain.writerow(["Matricule", "Login"])

        logins = []

        for salarie in lecteurs:
            matricule = salarie["Matricule"].strip()
            prenom = salarie["Prénom"].strip()
            nom = salarie["Nom"].strip()

            # Garder l'ancien login si le salarié existe déjà
            if matricule in anciens:
                login = anciens[matricule]

            else:
                # Créer le login
                login = prenom[0] + nom

                # Supprimer les accents
                login = unicodedata.normalize("NFD", login)
                login = "".join(c for c in login if unicodedata.category(c) != "Mn")

                # Mettre en minuscules
                login = login.lower()

                # Garder uniquement les lettres et chiffres
                login = "".join(c for c in login if c.isalnum())

                # Limiter à 8 caractères
                login = login[:8]

                # Vérifier les doublons
                base = login[:6]
                compteur = 1

                while login in logins:
                    login = base + str(compteur).zfill(2)
                    compteur += 1

            logins.append(login)

            # Enregistrer le salarié
            ecrivain.writerow([matricule, login])

            print(matricule, login)
