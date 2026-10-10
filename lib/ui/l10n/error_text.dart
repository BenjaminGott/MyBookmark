import '../../core/failure.dart';
import 'l10n.dart';

/// Le message à montrer pour un échec, dans la langue de l'interface.
extension AppExceptionText on AppException {
  String describe(AppLocalizations l10n) => switch (reason) {
    AppErrorReason.network => l10n.errorNetwork,
    AppErrorReason.timeout => l10n.errorTimeout,
    AppErrorReason.server => l10n.errorServer,
    AppErrorReason.malformedResponse => l10n.errorMalformedResponse,
    AppErrorReason.cancelled => l10n.errorCancelled,
    AppErrorReason.duplicateBook => l10n.errorDuplicateBook,
    AppErrorReason.saveFailed => l10n.errorSaveFailed,
    AppErrorReason.bookReadFailed => l10n.errorBookReadFailed,
    AppErrorReason.libraryReadFailed => l10n.errorLibraryReadFailed,
    AppErrorReason.malformedBackup => l10n.errorMalformedBackup,
    AppErrorReason.malformedGoodreads => l10n.errorMalformedGoodreads,
    AppErrorReason.backupUntitledBook => l10n.errorBackupUntitledBook,
    AppErrorReason.backupUnknownShelf => l10n.errorBackupUnknownShelf,
    AppErrorReason.backupNotText => l10n.errorBackupNotText,
    AppErrorReason.backupTooRecent => l10n.errorBackupTooRecent,
    AppErrorReason.fileAccess => l10n.errorFileAccess,
    AppErrorReason.fileRead => l10n.errorFileRead,
    AppErrorReason.exportLocation => l10n.errorExportLocation,
    AppErrorReason.imageRead => l10n.errorImageRead,
    AppErrorReason.imageCopy => l10n.errorImageCopy,
    AppErrorReason.imagePrepare => l10n.errorImagePrepare,
    AppErrorReason.shareFailed => l10n.errorShareFailed,
    AppErrorReason.instagramFailed => l10n.errorInstagramFailed,
    AppErrorReason.photoAccess => l10n.errorPhotoAccess,
    AppErrorReason.notEnoughSpace => l10n.errorNotEnoughSpace,
    AppErrorReason.imageSaveFailed => l10n.errorImageSaveFailed,
  };
}
