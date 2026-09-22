import '../../domain/models/backup.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/services/text_normalizer.dart';
import '../backup/backup_codec.dart';
import '../local/app_database.dart';

/// Export et import JSON adossés à la base drift.
class JsonBackupRepository implements BackupRepository {
  JsonBackupRepository({
    required this.database,
    this.normalizer = const TextNormalizer(),
  });

  final AppDatabase database;
  final TextNormalizer normalizer;

  @override
  Future<String> exportJson() async {
    final archive = BackupArchive(
      exportedAt: DateTime.now(),
      books: await database.backupDao.readAllBooks(),
      tags: await database.backupDao.readAllTagNames(),
    );
    return BackupCodec.encode(archive);
  }

  @override
  String suggestedFileName({DateTime? now}) {
    final date = now ?? DateTime.now();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'biblivre-${date.year}-$month-$day.json';
  }

  @override
  Future<BackupSummary> inspect(String json) async {
    final archive = BackupCodec.decode(json);
    final existing =
        await database.backupDao.readBookIdentities(_manualIdentity);

    var alreadyPresent = 0;
    for (final book in archive.books) {
      if (existing.contains(_identityOf(book))) {
        alreadyPresent++;
      }
    }

    return BackupSummary(
      version: archive.version,
      exportedAt: archive.exportedAt,
      bookCount: archive.books.length,
      readingCount: archive.readingCount,
      alreadyPresentCount: alreadyPresent,
      libraryCount: await database.backupDao.countBooks(),
    );
  }

  @override
  Future<ImportReport> import(
    String json, {
    required ImportMode mode,
  }) async {
    final archive = BackupCodec.decode(json);
    final now = DateTime.now();

    if (mode == ImportMode.replace) {
      await database.backupDao.deleteEverything();
    }

    // Recalculé après l'éventuelle suppression, et tenu à jour au fil de
    // l'import pour dédoublonner aussi à l'intérieur du fichier.
    final existing = await database.backupDao.readBookIdentities(_manualIdentity);

    var imported = 0;
    var skipped = 0;
    var readings = 0;

    for (final book in archive.books) {
      final identity = _identityOf(book);
      if (existing.contains(identity)) {
        skipped++;
        continue;
      }

      readings += await database.backupDao.insertBackupBook(book, now: now);
      existing.add(identity);
      imported++;
    }

    // Les étagères sans livre sont recréées telles quelles : ce sont des
    // rangements que l'utilisateur a voulus.
    for (final name in archive.tags) {
      await database.tagsDao.ensureTag(name, now: now);
    }

    return ImportReport(
      mode: mode,
      booksImported: imported,
      booksSkipped: skipped,
      readingsImported: readings,
      tagsImported: (await database.backupDao.readAllTagNames()).length,
    );
  }

  /// L'identité d'un livre pour le dédoublonnage.
  ///
  /// La clé Open Library fait foi quand elle existe. Sinon — livres saisis à la
  /// main — on compare titre et auteur normalisés, pour que « Dune » et
  /// « dune » ne soient pas importés deux fois.
  String _identityOf(BackupBook book) =>
      book.olKey ?? _manualIdentity(book.title, book.author);

  String _manualIdentity(String title, String? author) {
    final normalizedTitle = normalizer.normalize(title);
    final normalizedAuthor = normalizer.normalize(author ?? '');
    return 'manuel:$normalizedTitle|$normalizedAuthor';
  }
}
