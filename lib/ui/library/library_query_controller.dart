import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/library_item.dart';
import '../../domain/models/library_query.dart';
import '../../domain/models/shelf.dart';
import '../providers/book_providers.dart';

/// Le filtre et le tri choisis dans « Ma bibliothèque ».
///
/// Ce n'est qu'un état d'écran : il n'est pas enregistré, la bibliothèque
/// s'ouvre toujours sur les derniers livres ajoutés.
class LibraryQueryController extends Notifier<LibraryQuery> {
  @override
  LibraryQuery build() => const LibraryQuery();

  /// `null` affiche toutes les étagères.
  void filterByShelf(Shelf? shelf) {
    state = state.copyWith(shelf: () => shelf);
  }

  /// Choisit un critère de tri. Rechoisir le même inverse le sens.
  void sortBy(LibrarySort sort) {
    if (state.sort == sort) {
      state = state.copyWith(descending: !state.descending);
      return;
    }
    // Les dates et les notes se lisent mieux du plus grand au plus petit, les
    // titres et les auteurs dans l'ordre alphabétique.
    state = state.copyWith(
      sort: sort,
      descending: sort == LibrarySort.addedAt || sort == LibrarySort.rating,
    );
  }
}

final NotifierProvider<LibraryQueryController, LibraryQuery>
    libraryQueryProvider =
    NotifierProvider<LibraryQueryController, LibraryQuery>(
  LibraryQueryController.new,
);

/// La bibliothèque telle que l'écran la montre, filtre et tri compris.
///
/// Un seul provider pour tous les filtres : changer d'étagère relance la
/// requête sans détruire le flux, ce qui permet de garder la liste précédente
/// affichée pendant le rechargement au lieu de faire clignoter un sablier.
final StreamProvider<List<LibraryItem>> currentLibraryProvider =
    StreamProvider<List<LibraryItem>>((ref) {
  final query = ref.watch(libraryQueryProvider);
  return ref.watch(bookRepositoryProvider).watchLibrary(query);
});
