import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../l10n/l10n.dart';
import '../widgets/readable_width.dart';
import '../widgets/status_views.dart';
import 'year_review_providers.dart';
import 'year_review_screen.dart';

/// Réglages → Mes bilans : un bilan par année terminée.
class YearReviewsScreen extends ConsumerWidget {
  const YearReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final years = ref.watch(yearReviewYearsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsYearReviews)),
      body: ReadableWidth(
        child: years.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            error: error is AppException
                ? error
                : const StorageException(AppErrorReason.libraryReadFailed),
          ),
          data: (years) => years.isEmpty
              ? EmptyState(
                  icon: Icons.insights_outlined,
                  title: l10n.yearReviewsEmptyTitle,
                  message: l10n.yearReviewsEmptyMessage,
                )
              : ListView(
                  padding: EdgeInsets.only(
                    bottom: 16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: <Widget>[
                    for (final summary in years)
                      ListTile(
                        leading: const Icon(Icons.insights_outlined),
                        title: Text(l10n.yearReviewTitle('${summary.year}')),
                        subtitle: summary.review == null
                            ? Text(l10n.yearReviewsNew)
                            : Text(
                                l10n.yearReviewsSummary(
                                  summary.review!.bookCount,
                                  summary.review!.pagesRead,
                                ),
                              ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  YearReviewScreen(year: summary.year),
                            ),
                          );
                          // Ouvrir un bilan le crée : la liste le montre.
                          ref.invalidate(yearReviewYearsProvider);
                        },
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
