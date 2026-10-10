import '../../core/failure.dart';
import '../../domain/models/backup.dart';
import '../../domain/models/shelf.dart';

/// Lit l'export CSV de Goodreads (*My Books → Import and export*) et le
/// traduit en archive MyBookmark, que l'import habituel sait appliquer.
///
/// Ce que Goodreads ne donne pas reste vide : la couverture est retrouvée
/// par l'ISBN chez Open Library, et un livre « en cours » repart de la page 0,
/// l'export n'indiquant pas la page atteinte.
class GoodreadsCsv {
  const GoodreadsCsv._();

  /// Les colonnes sans lesquelles le fichier n'est pas un export Goodreads.
  static const List<String> _required = <String>['Title', 'Exclusive Shelf'];

  static BackupArchive decode(String csv, {DateTime? now}) {
    final rows = parseCsv(csv);
    if (rows.isEmpty) {
      throw const MalformedBackupException(AppErrorReason.malformedGoodreads);
    }

    final header = rows.first.map((name) => name.trim()).toList();
    final column = <String, int>{
      for (var i = 0; i < header.length; i++) header[i]: i,
    };
    if (!_required.every(column.containsKey)) {
      throw const MalformedBackupException(AppErrorReason.malformedGoodreads);
    }

    String? cell(List<String> row, String name) {
      final index = column[name];
      if (index == null || index >= row.length) {
        return null;
      }
      final value = row[index].trim();
      return value.isEmpty ? null : value;
    }

    final books = <BackupBook>[];
    for (final row in rows.skip(1)) {
      final rawTitle = cell(row, 'Title');
      if (rawTitle == null) {
        continue;
      }

      final exclusive = cell(row, 'Exclusive Shelf') ?? 'to-read';
      final shelf = _shelfOf(exclusive);
      final pageCount = _positive(cell(row, 'Number of Pages'));
      final rating = _positive(cell(row, 'My Rating'));
      final dateRead = _date(cell(row, 'Date Read'));
      final dateAdded = _date(cell(row, 'Date Added'));
      final isbn = _isbn(cell(row, 'ISBN13')) ?? _isbn(cell(row, 'ISBN'));

      // Les étagères personnalisées deviennent des étiquettes. Une étagère
      // exclusive inconnue (« did-not-finish »…) aussi : le livre va dans
      // « À lire », mais l'information n'est pas perdue.
      final tags = <String>{
        ...?cell(row, 'Bookshelves')
            ?.split(',')
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty && !_standard.contains(name)),
        if (shelf == null) exclusive,
      }.toList();

      books.add(
        BackupBook(
          title: _withoutSeries(rawTitle),
          author: cell(row, 'Author'),
          pageCount: pageCount,
          isbn: isbn,
          coverUrl: isbn == null
              ? null
              : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg'
                    '?default=false',
          firstPublishYear:
              _positive(cell(row, 'Original Publication Year')) ??
              _positive(cell(row, 'Year Published')),
          isManual: false,
          createdAt: dateAdded,
          tags: tags,
          readings: <BackupReading>[
            BackupReading(
              shelf: shelf ?? Shelf.toRead,
              currentPage: shelf == Shelf.read ? (pageCount ?? 0) : 0,
              isCurrent: true,
              rating: rating == null || rating > 5 ? null : rating,
              review: _plainText(cell(row, 'My Review')),
              startedAt: shelf == Shelf.reading ? dateRead : null,
              finishedAt: shelf == Shelf.read ? dateRead : null,
              createdAt: dateAdded,
            ),
          ],
        ),
      );
    }

    return BackupArchive(exportedAt: now ?? DateTime.now(), books: books);
  }

  static const Set<String> _standard = <String>{
    'read',
    'currently-reading',
    'to-read',
  };

  static Shelf? _shelfOf(String exclusive) => switch (exclusive) {
    'read' => Shelf.read,
    'currently-reading' => Shelf.reading,
    'to-read' => Shelf.toRead,
    _ => null,
  };

  /// « Le Chevalier et la Phalène (Le Royaume d'Eauroche, #1) » →
  /// « Le Chevalier et la Phalène » : Goodreads colle la série au titre.
  static String _withoutSeries(String title) {
    final cleaned = title.replaceFirst(
      RegExp(r'\s*\([^()]*#\s*[\d.–-]+\)\s*$'),
      '',
    );
    return cleaned.isEmpty ? title : cleaned;
  }

  /// Goodreads écrit les ISBN `="9782070612758"` pour qu'Excel ne les
  /// transforme pas en nombres.
  static String? _isbn(String? raw) {
    if (raw == null) {
      return null;
    }
    final digits = raw.replaceAll(RegExp('[^0-9Xx]'), '').toUpperCase();
    return digits.length == 10 || digits.length == 13 ? digits : null;
  }

  static int? _positive(String? raw) {
    final value = int.tryParse(raw ?? '');
    return value != null && value > 0 ? value : null;
  }

  /// Dates au format `2026/09/22`.
  static DateTime? _date(String? raw) {
    final parts = raw?.split('/');
    if (parts == null || parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  /// Les avis Goodreads contiennent du HTML simple (`<br/>`, `<i>`…).
  static String? _plainText(String? html) {
    if (html == null) {
      return null;
    }
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
    return text.isEmpty ? null : text;
  }
}

/// Découpe un CSV (RFC 4180) : champs entre guillemets, guillemets doublés,
/// retours à la ligne dans un champ.
List<List<String>> parseCsv(String input) {
  final text = input.startsWith('﻿') ? input.substring(1) : input;
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (row.length > 1 || row.first.isNotEmpty) {
      rows.add(row);
    }
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (quoted) {
      if (char == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(char);
      }
    } else if (char == '"') {
      quoted = true;
    } else if (char == ',') {
      endField();
    } else if (char == '\n') {
      endRow();
    } else if (char != '\r') {
      field.write(char);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    endRow();
  }
  return rows;
}
