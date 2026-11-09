import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/year_review_season.dart';
import 'book_detail/book_detail_screen.dart';
import 'l10n/l10n.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';
import 'widgets/readable_width.dart';
import 'year_review/year_review_providers.dart';
import 'year_review/year_review_screen.dart';

/// Les deux onglets de l'application : sa bibliothèque, et la recherche.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// En janvier, l'année dont le bilan a son onglet.
  int? _reviewTabYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _yearReviewSeason());
  }

  /// Le bilan de l'année écoulée, selon le mois : son onglet tout janvier,
  /// et une fenêtre aux deux premiers lancements de janvier puis de février.
  Future<void> _yearReviewSeason() async {
    final YearReviewSeasonState? season;
    try {
      season = await ref.read(yearReviewSeasonProvider.future);
      if (season == null) {
        return;
      }
      // Le bilan est créé (et figé) avant d'être montré.
      await ref.read(yearReviewProvider(season.year).future);
    } on Object {
      // Le bilan est un plus : un souci de lecture ne gêne pas le lancement.
      return;
    }
    if (!mounted) {
      return;
    }
    if (season.tab) {
      setState(() => _reviewTabYear = season!.year);
    }
    final notice = season.notice;
    if (notice == null) {
      return;
    }
    await ref
        .read(yearReviewRepositoryProvider)
        .markNoticeShown(notice, season.year);
    if (!mounted) {
      return;
    }
    final open = await _showNotice(notice, season.year);
    if (open != true || !mounted) {
      return;
    }
    if (notice == YearReviewNotice.january) {
      setState(() => _index = _reviewTabIndex);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => YearReviewScreen(year: season!.year),
        ),
      );
    }
  }

  Future<bool?> _showNotice(YearReviewNotice notice, int year) {
    final l10n = context.l10n;
    final january = notice == YearReviewNotice.january;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(january ? Icons.insights : Icons.settings_outlined),
        title: Text(
          january
              ? l10n.yearReviewAnnounceTitle('$year')
              : l10n.yearReviewMovedTitle('$year'),
        ),
        content: Text(
          january
              ? l10n.yearReviewAnnounceBody
              : l10n.yearReviewMovedBody('$year'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              january ? l10n.yearReviewAnnounceLater : l10n.yearReviewMovedOk,
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              january ? l10n.yearReviewAnnounceOpen : l10n.yearReviewMovedOpen,
            ),
          ),
        ],
      ),
    );
  }

  /// L'onglet du bilan se glisse avant les réglages.
  static const int _reviewTabIndex = 2;

  void _goToSearch() => setState(() => _index = 1);

  void _openBook(int bookId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BookDetailScreen(bookId: bookId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reviewYear = _reviewTabYear;
    // IndexedStack garde l'état des onglets : revenir à la recherche
    // retrouve la saisie et les résultats.
    final pages = IndexedStack(
      index: _index,
      children: <Widget>[
        LibraryScreen(onOpenSearch: _goToSearch, onOpenBook: _openBook),
        const SearchScreen(),
        if (reviewYear != null) YearReviewScreen(year: reviewYear),
        const SettingsScreen(),
      ],
    );
    void select(int index) => setState(() => _index = index);

    // Tablette : les onglets passent dans un rail à gauche, comme dans les
    // applications Google, plutôt qu'une barre étirée tout en bas.
    if (MediaQuery.sizeOf(context).width >= kTabletWidth) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: select,
                labelType: NavigationRailLabelType.all,
                destinations: <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: const Icon(Icons.library_books_outlined),
                    selectedIcon: const Icon(Icons.library_books),
                    label: Text(l10n.navLibrary),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.search),
                    label: Text(l10n.navSearch),
                  ),
                  if (reviewYear != null)
                    NavigationRailDestination(
                      icon: const Icon(Icons.insights_outlined),
                      selectedIcon: const Icon(Icons.insights),
                      label: Text(l10n.yearReviewTitle('$reviewYear')),
                    ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: Text(l10n.navSettings),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: select,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.navSearch,
          ),
          if (reviewYear != null)
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights),
              label: l10n.yearReviewTitle('$reviewYear'),
            ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
