// Régénère db.json : tâches, cours et utilisateurs de démonstration.
//
// Les échéances sont calculées à partir d'aujourd'hui, pour que l'écran
// « Cette semaine » reste réaliste quel que soit le jour de la démo.
//
//   npm run reset   → écrase db.json avec des données neuves

const fs = require('fs');
const path = require('path');

const now = new Date();

/** Date locale au format ISO 8601 sans fuseau, lue par DateTime.parse. */
function at(days, hour, minute = 0) {
  const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + days, hour, minute);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}` +
    `T${pad(d.getHours())}:${pad(d.getMinutes())}:00`;
}

const db = {
  taches: [
    {
      id: 't1',
      titre: 'Rendu TP Dart',
      coursId: 'dm',
      echeance: at(0, 23, 59),
      terminee: false,
      description: 'Modèles Task, Course et User avec leurs tests. Déposer le fichier .zip sur la plateforme.',
      rappel: 'sameDay',
    },
    {
      id: 't2',
      titre: 'Dossier de conception v1',
      coursId: 'dm',
      echeance: at(1, 18),
      terminee: false,
      description: 'Persona, parcours, wireframes et design system v1 de CampusFlow.',
      rappel: 'dayBefore',
    },
    {
      id: 't3',
      titre: 'Projet Flutter — maquette',
      coursId: 'dm',
      echeance: at(2, 17),
      terminee: false,
      description: 'Maquette haute fidélité des écrans principaux de CampusFlow, à partir du design system v1. Déposer le lien sur la plateforme.',
      rappel: 'dayBefore',
    },
    {
      id: 't4',
      titre: 'Exposé en binôme',
      coursId: 'fd',
      echeance: at(2, 8),
      terminee: false,
      description: null,
      rappel: 'dayBefore',
    },
    {
      id: 't5',
      titre: 'Fiche persona',
      coursId: 'dm',
      echeance: at(-1, 18),
      terminee: true,
      description: null,
      rappel: 'dayBefore',
    },
    {
      id: 't6',
      titre: 'Lecture : arbres de décision',
      coursId: 'aa',
      echeance: at(-2, 10),
      terminee: true,
      description: null,
      rappel: 'none',
    },
  ],
  cours: [
    { id: 'dm', nom: 'Développement mobile', enseignant: 'M. Compaoré' },
    { id: 'fd', nom: 'Fouille de données', enseignant: 'Mme Ouédraogo' },
    { id: 'aa', nom: 'Apprentissage automatique', enseignant: 'M. Sawadogo' },
    { id: 'st', nom: 'Statistiques', enseignant: 'Mme Traoré' },
    { id: 'at', nom: 'Anglais technique', enseignant: 'Mme Zongo' },
    { id: 'gp', nom: 'Gestion de projet', enseignant: 'M. Ilboudo' },
  ],
  utilisateurs: [
    {
      id: 'u1',
      nom: 'Ibrahim Kaboré',
      initiales: 'IK',
      email: 'ibrahim.kabore@universite.bf',
      programme: 'Master 1 Intelligence Artificielle',
      // Faux serveur de TP : mot de passe en clair, jamais en production.
      motDePasse: 'campus2026',
    },
  ],
};

const fichier = path.join(__dirname, 'db.json');
fs.writeFileSync(fichier, JSON.stringify(db, null, 2) + '\n');
console.log(`db.json régénéré : ${db.taches.length} tâches, ${db.cours.length} cours, ${db.utilisateurs.length} utilisateur.`);
