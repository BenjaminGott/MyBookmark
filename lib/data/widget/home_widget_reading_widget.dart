import 'dart:async';

import 'package:home_widget/home_widget.dart';

import '../../domain/repositories/reading_widget.dart';

/// [ReadingWidget] adossé à `home_widget` : les données sont écrites dans
/// les préférences partagées, puis le widget natif (ReadingWidgetProvider)
/// est redessiné.
class HomeWidgetReadingWidget implements ReadingWidget {
  const HomeWidgetReadingWidget();

  static const String _provider =
      'com.libergot.mybookmark.ReadingWidgetProvider';

  @override
  Future<void> show(
    ReadingWidgetContent? content, {
    required String emptyTitle,
    required String emptyHint,
  }) async {
    try {
      await HomeWidget.saveWidgetData<bool>('has_book', content != null);
      await HomeWidget.saveWidgetData<String>('empty_title', emptyTitle);
      await HomeWidget.saveWidgetData<String>('empty_hint', emptyHint);
      if (content != null) {
        await HomeWidget.saveWidgetData<int>('book_id', content.bookId);
        await HomeWidget.saveWidgetData<String>('kicker', content.kicker);
        await HomeWidget.saveWidgetData<String>('title', content.title);
        await HomeWidget.saveWidgetData<String>('author', content.author);
        await HomeWidget.saveWidgetData<String>('progress', content.progress);
        await HomeWidget.saveWidgetData<int>('percent', content.percent ?? -1);
        final cover = content.cover;
        if (cover == null) {
          await HomeWidget.saveWidgetData<String>('cover', null);
        } else {
          await HomeWidget.saveFile('cover', cover, extension: 'png');
        }
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } on Object {
      // Pas de widget posé, ou plateforme sans widget : rien à mettre à jour.
    }
  }

  @override
  Future<int?> launchedBook() async {
    try {
      return _bookOf(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } on Object {
      return null;
    }
  }

  @override
  Stream<int> get tappedBooks => HomeWidget.widgetClicked
      .map(_bookOf)
      .where((id) => id != null)
      .cast<int>()
      .handleError((Object _) {});

  /// `mybookmark://book/12` → 12.
  static int? _bookOf(Uri? uri) {
    if (uri == null || uri.host != 'book' || uri.pathSegments.isEmpty) {
      return null;
    }
    return int.tryParse(uri.pathSegments.first);
  }
}
