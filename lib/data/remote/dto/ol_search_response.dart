import '../../../domain/models/book_search_result.dart';

/// Lecture des réponses d'Open Library.
///
/// L'API est publique, gratuite et sans garantie : un champ peut manquer,
/// arriver avec le mauvais type, ou contenir `null` au milieu d'une liste.
/// Toutes les méthodes ici sont donc défensives et ne lèvent jamais
/// d'exception : un document illisible est écarté, un champ douteux est ignoré.
class OpenLibraryParser {
  const OpenLibraryParser._();

  /// Transforme le corps de `/search.json` en résultats exploitables.
  ///
  /// Les documents sans clé ou sans titre sont écartés : sans eux, impossible
  /// d'ajouter le livre ni de l'afficher.
  static List<BookSearchResult> parseSearchResponse(Object? json) {
    if (json is! Map<String, Object?>) {
      return const <BookSearchResult>[];
    }

    final docs = json['docs'];
    if (docs is! List<Object?>) {
      return const <BookSearchResult>[];
    }

    final results = <BookSearchResult>[];
    for (final doc in docs) {
      final result = parseSearchDoc(doc);
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  /// Transforme un document de recherche, ou renvoie `null` s'il est inutilisable.
  static BookSearchResult? parseSearchDoc(Object? json) {
    if (json is! Map<String, Object?>) {
      return null;
    }

    final key = _asNonEmptyString(json['key']);
    final title = _asNonEmptyString(json['title']);
    if (key == null || title == null) {
      return null;
    }

    return BookSearchResult(
      olKey: key,
      title: title,
      author: _firstAuthor(json['author_name']),
      pageCount: _asPositiveInt(json['number_of_pages_median']),
      coverId: _asPositiveInt(json['cover_i']),
      firstPublishYear: _asPositiveInt(json['first_publish_year']),
    );
  }

  /// Extrait le résumé d'une œuvre (`/works/OL....json`).
  ///
  /// Open Library écrit ce champ de deux façons : soit directement une chaîne,
  /// soit un objet `{"type": "/type/text", "value": "..."}`.
  static String? parseWorkDescription(Object? json) {
    if (json is! Map<String, Object?>) {
      return null;
    }

    final description = json['description'];
    if (description is String) {
      return _cleanDescription(description);
    }
    if (description is Map<String, Object?>) {
      final value = description['value'];
      if (value is String) {
        return _cleanDescription(value);
      }
    }
    return null;
  }

  /// Le premier auteur cité, les suivants n'étant pas affichés en v1.
  static String? _firstAuthor(Object? value) {
    if (value is String) {
      return _asNonEmptyString(value);
    }
    if (value is List<Object?>) {
      for (final entry in value) {
        final author = _asNonEmptyString(entry);
        if (author != null) {
          return author;
        }
      }
    }
    return null;
  }

  static String? _asNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Un entier strictement positif, ou `null`.
  ///
  /// Un nombre de pages à 0 ou négatif vaut « inconnu » : c'est aussi ce que
  /// la contrainte CHECK de la table `books` impose.
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

  /// Retire la ligne de crédit que Open Library colle souvent en fin de résumé.
  static String? _cleanDescription(String raw) {
    var text = raw.trim();
    final separator = text.indexOf('----------');
    if (separator > 0) {
      text = text.substring(0, separator).trim();
    }
    return text.isEmpty ? null : text;
  }
}
