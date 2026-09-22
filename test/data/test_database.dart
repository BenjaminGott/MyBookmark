import 'package:biblivre/data/local/app_database.dart';
import 'package:drift/native.dart';

/// Réexporté pour les tests qui vérifient qu'une contrainte SQL a bien sauté.
export 'package:drift/native.dart' show SqliteException;

/// Une base neuve, en mémoire, pour un test.
///
/// `NativeDatabase.memory()` crée un SQLite complet dans le processus de test :
/// les contraintes, les index et les triggers sont donc réellement exercés.
AppDatabase createTestDatabase() =>
    AppDatabase.withExecutor(NativeDatabase.memory());
