import 'dart:convert';

import '../../core/failure.dart';
import '../../domain/models/backup.dart';
import '../../domain/models/shelf.dart';

/// Lecture et écriture du fichier de sauvegarde JSON.
///
/// Le format est volontairement lisible à l'œil et sans identifiants locaux :
/// les lectures et les étagères sont imbriquées dans leur livre, ce qui rend le
/// fichier compréhensible et l'import facile à dédoublonner.
///
/// À la lecture, rien n'est supposé : un fichier tronqué, écrit à la main ou
/// venu d'une autre application lève une [MalformedBackupException] plutôt que
/// de laisser passer des données à moitié valides.
class BackupCodec {
  const BackupCodec._();

  /// Sérialise l'archive, indentée pour rester relisible.
  static String encode(BackupArchive archive) {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': archive.version,
      'exportedAt': archive.exportedAt.toUtc().toIso8601String(),
      'tags': archive.tags,
      'books': <Object?>[
        for (final book in archive.books) _encodeBook(book),
      ],
    });
  }

  static Map<String, Object?> _encodeBook(BackupBook book) {
    return <String, Object?>{
      'olKey': book.olKey,
      'title': book.title,
      'author': book.author,
      'pageCount': book.pageCount,
      'coverId': book.coverId,
      'coverUrl': book.coverUrl,
      'firstPublishYear': book.firstPublishYear,
      'description': book.description,
      'isbn': book.isbn,
      'isManual': book.isManual,
      'createdAt': _encodeDate(book.createdAt),
      'tags': book.tags,
      'readings': <Object?>[
        for (final reading in book.readings)
          <String, Object?>{
            'shelf': reading.shelf.wireName,
            'rating': reading.rating,
            'review': reading.review,
            'startedAt': _encodeDate(reading.startedAt),
            'finishedAt': _encodeDate(reading.finishedAt),
            'currentPage': reading.currentPage,
            'isCurrent': reading.isCurrent,
            'createdAt': _encodeDate(reading.createdAt),
          },
      ],
    };
  }

  /// Désérialise un fichier. Lève une [AppException] rédigée en français si le
  /// contenu ne tient pas debout.
  static BackupArchive decode(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      throw const MalformedBackupException();
    }

    if (json is! Map<String, Object?>) {
      throw const MalformedBackupException();
    }

    final version = json['version'];
    if (version is! int) {
      throw const MalformedBackupException();
    }
    if (version > kBackupFormatVersion) {
      throw UnsupportedBackupVersionException(version);
    }

    final rawBooks = json['books'];
    if (rawBooks is! List<Object?>) {
      throw const MalformedBackupException();
    }

    return BackupArchive(
      version: version,
      exportedAt: _decodeDate(json['exportedAt']) ?? DateTime.now(),
      tags: _decodeStringList(json['tags']),
      books: <BackupBook>[
        for (final rawBook in rawBooks) _decodeBook(rawBook),
      ],
    );
  }

  static BackupBook _decodeBook(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const MalformedBackupException();
    }

    final title = _asNonEmptyString(json['title']);
    if (title == null) {
      // Un livre sans titre ne peut pas être inséré : la base le refuserait.
      throw const MalformedBackupException(
        AppErrorReason.backupUntitledBook,
      );
    }

    final rawReadings = json['readings'];
    final readings = <BackupReading>[
      if (rawReadings is List<Object?>)
        for (final rawReading in rawReadings) _decodeReading(rawReading),
    ];

    return BackupBook(
      olKey: _asNonEmptyString(json['olKey']),
      title: title,
      author: _asNonEmptyString(json['author']),
      pageCount: _asPositiveInt(json['pageCount']),
      coverId: _asPositiveInt(json['coverId']),
      coverUrl: _asNonEmptyString(json['coverUrl']),
      firstPublishYear: _asPositiveInt(json['firstPublishYear']),
      description: _asNonEmptyString(json['description']),
      isbn: _asNonEmptyString(json['isbn']),
      isManual: json['isManual'] == true,
      createdAt: _decodeDate(json['createdAt']),
      tags: _decodeStringList(json['tags']),
      readings: readings,
    );
  }

  static BackupReading _decodeReading(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const MalformedBackupException();
    }

    final rawShelf = json['shelf'];
    final shelf = rawShelf is String ? Shelf.tryParse(rawShelf) : null;
    if (shelf == null) {
      throw const MalformedBackupException(
        AppErrorReason.backupUnknownShelf,
      );
    }

    return BackupReading(
      shelf: shelf,
      rating: _asRating(json['rating']),
      review: _asNonEmptyString(json['review']),
      startedAt: _decodeDate(json['startedAt']),
      finishedAt: _decodeDate(json['finishedAt']),
      currentPage: _asPositiveInt(json['currentPage']) ?? 0,
      isCurrent: json['isCurrent'] == true,
      createdAt: _decodeDate(json['createdAt']),
    );
  }

  static String? _encodeDate(DateTime? date) =>
      date?.toUtc().toIso8601String();

  static DateTime? _decodeDate(Object? value) {
    if (value is! String) {
      return null;
    }
    // Une date illisible n'invalide pas la sauvegarde : le champ reste vide.
    return DateTime.tryParse(value)?.toLocal();
  }

  static List<String> _decodeStringList(Object? value) {
    if (value is! List<Object?>) {
      return const <String>[];
    }
    final names = <String>[];
    for (final entry in value) {
      final name = _asNonEmptyString(entry);
      if (name != null && !names.contains(name)) {
        names.add(name);
      }
    }
    return names;
  }

  static String? _asNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _asPositiveInt(Object? value) {
    final number = switch (value) {
      final int v => v,
      final double v => v.round(),
      final String v => int.tryParse(v.trim()),
      _ => null,
    };
    if (number == null || number <= 0) {
      return null;
    }
    return number;
  }

  /// Une note hors de 1 à 5 est ignorée plutôt que de faire échouer l'import :
  /// la contrainte de la base la refuserait de toute façon.
  static int? _asRating(Object? value) {
    final rating = _asPositiveInt(value);
    if (rating == null || rating > 5) {
      return null;
    }
    return rating;
  }
}
