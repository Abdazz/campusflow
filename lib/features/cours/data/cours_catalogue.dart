import 'package:campusflow/features/cours/domain/course.dart';

/// Catalogue des cours du semestre, identique à la collection `cours` de
/// `server/db.json`. Il change une fois par semestre : l'application le
/// garde en local pour afficher les noms sans attendre le réseau.
const sampleCourses = [
  Course(id: 'dm', name: 'Développement mobile', teacher: 'M. Compaoré'),
  Course(id: 'fd', name: 'Fouille de données', teacher: 'Mme Ouédraogo'),
  Course(id: 'aa', name: 'Apprentissage automatique', teacher: 'M. Sawadogo'),
  Course(id: 'st', name: 'Statistiques', teacher: 'Mme Traoré'),
  Course(id: 'at', name: 'Anglais technique', teacher: 'Mme Zongo'),
  Course(id: 'gp', name: 'Gestion de projet', teacher: 'M. Ilboudo'),
];

Course courseById(String id) => sampleCourses.firstWhere(
  (course) => course.id == id,
  orElse: () => Course(id: id, name: 'Cours inconnu', teacher: ''),
);
