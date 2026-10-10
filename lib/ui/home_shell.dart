import 'package:flutter/material.dart';

import 'book_detail/book_detail_screen.dart';
import 'l10n/l10n.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';
import 'widgets/readable_width.dart';

/// Les deux onglets de l'application : sa bibliothèque, et la recherche.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

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
    // IndexedStack garde l'état des onglets : revenir à la recherche
    // retrouve la saisie et les résultats.
    final pages = IndexedStack(
      index: _index,
      children: <Widget>[
        LibraryScreen(onOpenSearch: _goToSearch, onOpenBook: _openBook),
        const SearchScreen(),
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
