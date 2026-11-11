
#!/usr/bin/env python3

import csv
import os
import pwd
import grp
import unicodedata

FICHIER_UTILISATEURS = "config/tekitizy_users.csv"
FICHIER_LOGINS = "config/tekitizy_logins.csv"


def nettoyer_groupe(nom):
    nom = unicodedata.normalize("NFD", nom)
    nom = "".join(c for c in nom if unicodedata.category(c) != "Mn")
    nom = nom.lower().strip()
    nom = nom.replace(" ", "").replace("-", "").replace("'", "")
    nom = "".join(c for c in nom if c in "abcdefghijklmnopqrstuvwxyz0123456789_")
    return nom


def nettoyer_dossier(nom):
    nom = unicodedata.normalize("NFD", nom)
    nom = "".join(c for c in nom if unicodedata.category(c) != "Mn")
    nom = nom.upper().strip()
    nom = nom.replace(" ", "_").replace("-", "_").replace("'", "")
    nom = "".join(c for c in nom if c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    return nom


def configurer_dossier(chemin, groupe):
    try:
        gid = grp.getgrnam(groupe).gr_gid
    except KeyError:
        print("Erreur : groupe introuvable :", groupe)
        return

    os.makedirs(chemin, exist_ok=True)

    os.chown(chemin, 0, gid)
    os.chmod(chemin, 0o2770)

    print("Droits configurés :", chemin)


def main():
    if os.geteuid() != 0:
        print("Erreur : lancez ce programme avec sudo.")
        return

    logins = {}

    with open(FICHIER_LOGINS, newline="", encoding="utf-8") as fichier:
        lecteur = csv.DictReader(fichier)

        for ligne in lecteur:
            logins[ligne["Matricule"]] = ligne["Login"]

    with open(FICHIER_UTILISATEURS, newline="", encoding="utf-8") as fichier:
        lecteur = csv.DictReader(fichier)

        for ligne in lecteur:
            matricule = ligne["Matricule"]

            if matricule not in logins:
                print(f"Login introuvable pour {matricule}")
                continue

            login = logins[matricule]

            # Dossier personnel
            try:
                utilisateur = pwd.getpwnam(login)
                chemin_home = f"/home/{login}"

                os.makedirs(chemin_home, exist_ok=True)
                os.chown(chemin_home, utilisateur.pw_uid, utilisateur.pw_gid)
                os.chmod(chemin_home, 0o700)

                print(f"Dossier personnel configuré : {login}")

            except KeyError:
                print(f"Utilisateur introuvable : {login}")
                continue

            # Dossier du pôle
            pole = ligne["Pole"].strip()
            groupe_pole = nettoyer_groupe(pole)
            dossier_pole = nettoyer_dossier(pole)

            configurer_dossier(
                f"/SERVICES/{dossier_pole}",
                groupe_pole
            )

            # Dossier du sous-service
            sous_service = ligne["SousService"].strip()

            if sous_service:
                groupe_sous_service = nettoyer_groupe(sous_service)
                dossier_sous_service = nettoyer_dossier(sous_service)

                configurer_dossier(
                    f"/SERVICES/{dossier_pole}/{dossier_sous_service}",
                    groupe_sous_service
                )

            # Dossier du projet
            projets = ligne["Projet"].split(";")

            for projet in projets:
                projet = projet.strip()

                if projet:
                    groupe_projet = nettoyer_groupe(projet)
                    dossier_projet = nettoyer_dossier(projet)

                    configurer_dossier(
                        f"/PROJETS/{dossier_projet}",
                        groupe_projet
                    )

    # Dossier commun
    configurer_dossier("/SERVICES/COMMUN", "personnel")

    # Dossier des archives
    os.makedirs("/ARCHIVES", exist_ok=True)
    os.chown("/ARCHIVES", 0, 0)
    os.chmod("/ARCHIVES", 0o700)

    print("\nTEKITIZY : configuration des permissions terminée.")


if __name__ == "__main__":
    main()
