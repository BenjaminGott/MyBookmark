import 'package:flutter/material.dart';

import 'book_detail/book_detail_screen.dart';
import 'l10n/l10n.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';

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
    return Scaffold(
      // IndexedStack garde l'état des deux onglets : revenir à la recherche
      // retrouve la saisie et les résultats.
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          LibraryScreen(onOpenSearch: _goToSearch, onOpenBook: _openBook),
          const SearchScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: context.l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: context.l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
