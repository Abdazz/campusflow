# Séance 2 : UX/UI et Claude Design, dossier de conception v1

Le dossier a été conçu dans Claude Design (canevas « CampusFlow, Dossier de conception v1 ») :
https://claude.ai/artifact/H4TLqVRGjYeSzu3N83W3xS

Chaque planche est exportée ici en image (`images/`). Le code HTML source de chaque planche se trouve dans `sources/` et s'ouvre directement dans un navigateur.

## Maquette haute fidélité

Les cinq écrans de CampusFlow, en couleur, avec le design system v1 appliqué (tokens, police Figtree, composants). Ce sont ces écrans que l'application Flutter reproduit aux séances 4 à 7.

| H1 Connexion | H2 Échéances | H3 Détail | H4 Nouvelle tâche | H5 Cours |
|---|---|---|---|---|
| ![H1 Connexion](images/08_maquette_H1_connexion.png) | ![H2 Échéances](images/08_maquette_H2_echeances.png) | ![H3 Détail](images/08_maquette_H3_detail.png) | ![H4 Nouvelle tâche](images/08_maquette_H4_nouvelle_tache.png) | ![H5 Cours](images/08_maquette_H5_cours.png) |

### Trois variantes de l'écran Échéances en haute fidélité

| A Liste par jour (retenue) | B Groupée par cours | C Bandeau semaine |
|---|---|---|
| ![Variante A](images/09_maquette_variante_A.png) | ![Variante B](images/09_maquette_variante_B.png) | ![Variante C](images/09_maquette_variante_C.png) |

### Choix justifié après la haute fidélité

La grille du cours est appliquée de nouveau aux variantes en couleur : la variante A reste retenue (5 critères sur 5, contre 3 pour B et 0 pour C).

![Choix justifié après la haute fidélité](images/10_maquette_choix_justifie.png)

## Livrables demandés par le sujet

| Demandé par le sujet | Fichier |
|---|---|
| Persona et deux job stories (« Quand… je veux… pour… ») | [01_persona_job_stories.png](images/01_persona_job_stories.png) |
| Parcours « suivre mes échéances » en cinq étapes (action, friction, opportunité) | [02_parcours.png](images/02_parcours.png) |
| Cinq wireframes | [W1 Connexion](images/03_wireframe_W1_connexion.png), [W2 Échéances](images/03_wireframe_W2_echeances.png), [W3 Détail](images/03_wireframe_W3_detail.png), [W4 Nouvelle tâche](images/03_wireframe_W4_nouvelle_tache.png), [W5 Cours](images/03_wireframe_W5_cours.png) |
| Trois variantes d'un écran (Échéances) | [A Liste par jour](images/04_variante_A_par_jour.png), [B Groupée par cours](images/04_variante_B_par_cours.png), [C Bandeau semaine](images/04_variante_C_semaine.png) |
| Choix justifié avec la grille du cours (besoin, parcours, accessibilité, faisabilité) | [05_choix_justifie.png](images/05_choix_justifie.png) : la variante A est retenue (5 critères sur 5) |
| Design system v1 : couleurs, typographie, trois composants, tailles de fenêtre, contraste de 4,5:1 au minimum | [06_design_system_v1.png](images/06_design_system_v1.png) |

En plus : le logo « C-coche » ([07_logo.png](images/07_logo.png)) et la maquette haute fidélité présentée plus haut.

### Aperçu

| Persona | Parcours |
|---|---|
| ![Persona](images/01_persona_job_stories.png) | ![Parcours](images/02_parcours.png) |

| W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|
| ![W1](images/03_wireframe_W1_connexion.png) | ![W2](images/03_wireframe_W2_echeances.png) | ![W3](images/03_wireframe_W3_detail.png) | ![W4](images/03_wireframe_W4_nouvelle_tache.png) | ![W5](images/03_wireframe_W5_cours.png) |

| Variante A (retenue) | Variante B | Variante C |
|---|---|---|
| ![A](images/04_variante_A_par_jour.png) | ![B](images/04_variante_B_par_cours.png) | ![C](images/04_variante_C_semaine.png) |

![Design system v1](images/06_design_system_v1.png)

## Du design au code

La séance 4 reprend dans `lib/core/theme.dart` les tokens de la planche 6 :

- bleu campus `#2E3A8C` ;
- couleurs « urgent » et « terminé » ;
- police Figtree ;
- espacements.

Les écrans des séances 5 à 7 suivent les maquettes H1 à H5.
