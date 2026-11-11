
#!/usr/bin/env python3

import csv
import os
import pwd

FICHIER_UTILISATEURS = "config/tekitizy_users.csv"
FICHIER_LOGINS = "config/tekitizy_logins.csv"


def nettoyer_dossier(nom):
    import unicodedata

    nom = unicodedata.normalize("NFD", nom)
    nom = "".join(c for c in nom if unicodedata.category(c) != "Mn")
    nom = nom.upper().strip()
    nom = nom.replace(" ", "_").replace("-", "_").replace("'", "")
    nom = "".join(c for c in nom if c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")

    return nom


def creer_lien(source, destination):
    if not os.path.exists(destination) and not os.path.islink(destination):
        os.symlink(source, destination)


def main():

    if os.geteuid() != 0:
        print("Erreur : lancez ce programme avec sudo.")
        return

    logins = {}

    with open(FICHIER_LOGINS, newline="", encoding="utf-8") as fichier:
        lecteur = csv.DictReader(fichier)

        for ligne in lecteur:
            logins[ligne["Matricule"]] = ligne["Login"]

    os.makedirs("/SERVICES/COMMUN", exist_ok=True)
    os.makedirs("/PROJETS", exist_ok=True)
    os.makedirs("/ARCHIVES", exist_ok=True)

    with open(FICHIER_UTILISATEURS, newline="", encoding="utf-8-sig") as fichier:
        lecteur = csv.DictReader(fichier)

        for ligne in lecteur:

            matricule = ligne["Matricule"]

            if matricule not in logins:
                print("Login introuvable :", matricule)
                continue

            login = logins[matricule]

            try:
                utilisateur = pwd.getpwnam(login)
            except KeyError:
                print("Utilisateur introuvable :", login)
                continue

            # Dossiers du pôle et du sous-service
            pole = ligne["Pole"].strip()
            sous_service = ligne["SousService"].strip()

            dossier_pole = nettoyer_dossier(pole)

            if pole:
                os.makedirs("/SERVICES/" + dossier_pole, exist_ok=True)

            if pole and sous_service:
                dossier_service = nettoyer_dossier(sous_service)

                os.makedirs(
                    "/SERVICES/" + dossier_pole + "/" + dossier_service,
                    exist_ok=True
                )

            # Dossiers des projets
            projets = ligne["Projet"].split(";")

            for projet in projets:
                projet = projet.strip()

                if projet:
                    dossier_projet = nettoyer_dossier(projet)

                    os.makedirs(
                        "/PROJETS/" + dossier_projet,
                        exist_ok=True
                    )

            # Dossiers personnels
            dossier_personnel = "/home/" + login

            os.makedirs(dossier_personnel, exist_ok=True)

            os.chown(
                dossier_personnel,
                utilisateur.pw_uid,
                utilisateur.pw_gid
            )

            # Sous-dossiers personnels
            dossiers = [
                "Documents",
                "Projets",
                "Workspace",
                "Téléchargements",
                "Partage"
            ]

            for dossier in dossiers:
                chemin = dossier_personnel + "/" + dossier
                os.makedirs(chemin, exist_ok=True)

                os.chown(
                    chemin,
                    utilisateur.pw_uid,
                    utilisateur.pw_gid
                )

            # Liens symboliques des projets
            for projet in projets:
                projet = projet.strip()

                if projet:
                    dossier_projet = nettoyer_dossier(projet)

                    creer_lien(
                        "/PROJETS/" + dossier_projet,
                        dossier_personnel + "/Projets/" + dossier_projet
                    )

            # Lien du pôle dans Partage
            if pole:
                creer_lien(
                    "/SERVICES/" + dossier_pole,
                    dossier_personnel + "/Partage/" + dossier_pole
                )

            # Lien du sous-service dans Partage
            if pole and sous_service:
                dossier_service = nettoyer_dossier(sous_service)

                creer_lien(
                    "/SERVICES/" + dossier_pole + "/" + dossier_service,
                    dossier_personnel + "/Partage/" + dossier_service
                )

            print("Dossiers créés :", login)

    print("\nTEKITIZY : création des dossiers terminée.")


if __name__ == "__main__":
    main()
