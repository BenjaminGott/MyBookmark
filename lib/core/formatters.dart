import 'package:intl/intl.dart';

/// Mises en forme partagées par les écrans, toutes en français.
class Formatters {
  const Formatters._();

  static final DateFormat _longDate = DateFormat('d MMMM y', 'fr_FR');
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'fr_FR');

  /// « 14 mars 2026 ». Renvoie `null` si la date n'est pas renseignée.
  static String? longDate(DateTime? date) =>
      date == null ? null : _longDate.format(date);

  /// « 14/03/2026 », pour les endroits où la place manque.
  static String? shortDate(DateTime? date) =>
      date == null ? null : _shortDate.format(date);

  /// « 1 page » / « 658 pages », ou « pages inconnues ».
  static String pages(int? count) {
    if (count == null || count <= 0) {
      return 'Nombre de pages inconnu';
    }
    return count == 1 ? '1 page' : '$count pages';
  }
}
