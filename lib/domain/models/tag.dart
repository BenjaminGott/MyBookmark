import 'package:meta/meta.dart';

/// Une étagère personnalisée, librement nommée par l'utilisateur.
@immutable
class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
  });

  final int id;
  final String name;

  /// Couleur ARGB facultative, pour distinguer les étagères d'un coup d'œil.
  final int? color;

  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          other.id == id &&
          other.name == name &&
          other.color == color &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}
