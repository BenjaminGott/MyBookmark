import 'package:in_app_review/in_app_review.dart';

import '../../domain/repositories/review_prompt.dart';

/// [ReviewPrompt] adossé aux API officielles de Google Play et de l'App Store
/// (in_app_review).
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
      // Pas de boutique (émulateur, sideload) : on n'insiste pas.
    }
  }
}
