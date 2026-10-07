import 'package:in_app_review/in_app_review.dart';

import '../../domain/repositories/review_prompt.dart';

/// [ReviewPrompt] adossé à l'API officielle de Google Play (in_app_review).
class InAppReviewPrompt implements ReviewPrompt {
  const InAppReviewPrompt();

  @override
  Future<void> request() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } on Object {
      // Pas de Play Store (émulateur, sideload) : on n'insiste pas.
    }
  }
}
