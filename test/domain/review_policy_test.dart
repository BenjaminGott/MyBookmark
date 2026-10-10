import 'package:biblivre/domain/services/review_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7);

  test('attend deux livres terminés avant de demander un avis', () {
    expect(
      ReviewPolicy.shouldAsk(finishedBooks: 1, lastAsked: null, now: now),
      isFalse,
    );
    expect(
      ReviewPolicy.shouldAsk(finishedBooks: 2, lastAsked: null, now: now),
      isTrue,
    );
  });

  test('ne redemande pas avant soixante jours', () {
    expect(
      ReviewPolicy.shouldAsk(
        finishedBooks: 5,
        lastAsked: now.subtract(const Duration(days: 59)),
        now: now,
      ),
      isFalse,
    );
    expect(
      ReviewPolicy.shouldAsk(
        finishedBooks: 5,
        lastAsked: now.subtract(const Duration(days: 60)),
        now: now,
      ),
      isTrue,
    );
  });
}
