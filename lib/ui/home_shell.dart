import 'package:flutter/material.dart';

import 'book_detail/book_detail_screen.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';

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
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Bibliothèque',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Chercher',
          ),
        ],
      ),
    );
  }
}
