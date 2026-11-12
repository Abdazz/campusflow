import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clé du jeton d'authentification dans le stockage chiffré.
const cleJeton = 'campusflow.jeton';

/// Où ranger un secret. Jamais en clair : ni `shared_preferences`, ni un
/// fichier, ni une variable globale.
abstract interface class StockageSecurise {
  Future<String?> lire(String cle);
  Future<void> ecrire(String cle, String valeur);
  Future<void> effacer(String cle);
}

/// `flutter_secure_storage` : chiffré par le Keystore (Android) ou le
/// Keychain (iOS). Les valeurs lues sont gardées en mémoire pour ne pas
/// interroger le Keystore à chaque requête HTTP.
class StockageChiffre implements StockageSecurise {
  StockageChiffre([this._stockage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _stockage;
  final _cache = <String, String?>{};

  @override
  Future<String?> lire(String cle) async {
    if (_cache.containsKey(cle)) return _cache[cle];
    return _cache[cle] = await _stockage.read(key: cle);
  }

  @override
  Future<void> ecrire(String cle, String valeur) async {
    await _stockage.write(key: cle, value: valeur);
    _cache[cle] = valeur;
  }

  @override
  Future<void> effacer(String cle) async {
    await _stockage.delete(key: cle);
    _cache[cle] = null;
  }
}

/// Version en mémoire, pour les tests (le plugin natif n'y existe pas).
class StockageMemoire implements StockageSecurise {
  StockageMemoire([Map<String, String>? initial]) : valeurs = {...?initial};

  final Map<String, String> valeurs;

  @override
  Future<String?> lire(String cle) async => valeurs[cle];

  @override
  Future<void> ecrire(String cle, String valeur) async => valeurs[cle] = valeur;

  @override
  Future<void> effacer(String cle) async => valeurs.remove(cle);
}

final stockageSecuriseProvider = Provider<StockageSecurise>(
  (ref) => StockageChiffre(),
);
