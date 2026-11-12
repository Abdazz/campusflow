/// Fonctions utilitaires pour lire un champ JSON en vérifiant son type.
///
/// Chaque fonction lève une [FormatException] explicite si le champ est
/// absent ou n'a pas le type attendu, au lieu d'un `TypeError` peu lisible.
library;

T readField<T>(Map<String, dynamic> json, String key, String model) {
  final value = json[key];
  if (value is T) return value;
  if (value == null) {
    throw FormatException('$model : champ obligatoire "$key" manquant');
  }
  throw FormatException(
    '$model : "$key" doit être de type $T, reçu ${value.runtimeType}',
  );
}

T? readOptionalField<T>(Map<String, dynamic> json, String key, String model) {
  if (json[key] == null) return null;
  return readField<T>(json, key, model);
}

/// Identifiant : texte (`"t3"`, généré par json-server) ou entier (`42`).
String readId(Map<String, dynamic> json, String model) => switch (json['id']) {
  final String id when id.isNotEmpty => id,
  final int id => '$id',
  null => throw FormatException('$model : champ obligatoire "id" manquant'),
  final other => throw FormatException(
    '$model : "id" doit être un texte ou un entier, reçu ${other.runtimeType}',
  ),
};

DateTime readDate(Map<String, dynamic> json, String key, String model) {
  final raw = readField<String>(json, key, model);
  final date = DateTime.tryParse(raw);
  if (date == null) {
    throw FormatException('$model : "$key" n\'est pas une date ISO 8601', raw);
  }
  return date;
}
