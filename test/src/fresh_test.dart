import 'package:omelette/omelette.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Fresh tests |',
    () {
      test(
        'Fresh.yes factory redirects to WhenFresh',
        () {
          final freshness = Fresh.yes(
            entity: ['a'],
            isNextPageAvailable: true,
          );

          expect(freshness, isA<WhenFresh<List<String>>>());
          expect(
            freshness.toString(),
            'WhenFresh{entity: [a], isFresh: true, isNextPageAvailable: true}',
          );
        },
      );

      test(
        'Fresh.no factory redirects to WhenNotFresh',
        () {
          final freshness = Fresh.no(
            entity: ['a'],
            isNextPageAvailable: true,
          );

          expect(freshness, isA<WhenNotFresh<List<String>>>());
          expect(
            freshness.toString(),
            'WhenNotFresh{entity: [a], isFresh: false, isNextPageAvailable: true}',
          );
        },
      );
    },
  );
}
