import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/search_providers.dart';
import '../widgets/book_cover.dart';

/// Propose les couvertures trouvées en ligne pour [query], et renvoie celle
/// que l'utilisateur touche, ou `null` s'il ferme la feuille.
Future<BookSearchResult?> showCoverSearchSheet(
  BuildContext context, {
  required String query,
}) {
  return showModalBottomSheet<BookSearchResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CoverSearchSheet(initialQuery: query),
  );
}

class _CoverSearchSheet extends ConsumerStatefulWidget {
  const _CoverSearchSheet({required this.initialQuery});

  final String initialQuery;

  @override
  ConsumerState<_CoverSearchSheet> createState() => _CoverSearchSheetState();
}

class _CoverSearchSheetState extends ConsumerState<_CoverSearchSheet> {
  late final TextEditingController _field =
      TextEditingController(text: widget.initialQuery);
  late Stream<List<BookSearchResult>> _results = _search(widget.initialQuery);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Stream<List<BookSearchResult>> _search(String query) => ref
      .read(searchRepositoryProvider)
      .search(query)
      .map((results) => results.where((r) => r.hasCover).toList());

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _field,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: context.l10n.searchCover,
                  prefixIcon: const Icon(Icons.image_search),
                ),
                onSubmitted: (query) =>
                    setState(() => _results = _search(query)),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<BookSearchResult>>(
                stream: _results,
                builder: (context, snapshot) {
                  final error = snapshot.error;
                  if (error != null) {
                    return _Message(
                      error is AppException
                          ? error.describe(context.l10n)
                          : context.l10n.searchFailed,
                    );
                  }
                  final results = snapshot.data;
                  final done =
                      snapshot.connectionState == ConnectionState.done;
                  if (results == null || (results.isEmpty && !done)) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (results.isEmpty) {
                    return _Message(context.l10n.noCoverFound);
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 2 / 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return Semantics(
                        button: true,
                        label: result.title,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => Navigator.of(context).pop(result),
                          child: LayoutBuilder(
                            builder: (context, constraints) => BookCover(
                              url: result.coverUrl(),
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
