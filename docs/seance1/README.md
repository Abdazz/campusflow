# Séance 1 : Écosystème mobile

Livrable : [CampusFlow_Atelier1_Plateforme.pdf](CampusFlow_Atelier1_Plateforme.pdf)
(source Word : [CampusFlow_Atelier1_Plateforme.docx](CampusFlow_Atelier1_Plateforme.docx)).

| Demandé par le sujet | Où le trouver dans le document |
|---|---|
| Fiche comparative Android / iOS sur les 14 critères, appliquée à une application étudiante en Afrique francophone | Partie 1 (tableau à cinq colonnes, puis « Qu'est-ce qui change ? ») |
| Autopsie d'un système disparu : trois causes classées par poids, avec sources | Partie 2 : BlackBerry (virage tactile manqué 45 %, écosystème d'applications 35 %, exécution commerciale 20 %), sources Gartner, IDC, Reuters, CSMonitor, TechRadar |
| Paragraphe de décision pour CampusFlow : cible, plateformes, approche | Partie 3 : Android en priorité, iOS en second rang, cross-platform avec Flutter |

## Décision retenue (résumé)

- **Cible** : étudiants des universités du Burkina Faso et d'Afrique de l'Ouest francophone, sur smartphone Android d'entrée ou de milieu de gamme, avec un forfait de données limité.
- **Plateformes** : Android d'abord (94,4 % au Burkina Faso, StatCounter, septembre 2026), avec un minSdk bas. iOS ensuite, à partir de la même base de code.
- **Approche** : cross-platform avec Flutter. Une seule base de code, de bonnes performances sur du matériel modeste et pas de Mac obligatoire pour développer.

Cette décision fixe la suite du projet : la séance 4 crée le projet Flutter, et l'application vise d'abord l'émulateur Android.
