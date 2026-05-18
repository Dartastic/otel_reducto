// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_reducto/otel_reducto.dart';
import 'package:test/test.dart';

void main() {
  group('otel_reducto', () {
    test('suppression toggles in zone', () async {
      expect(reductoInstrumentationSuppressed(), isFalse);
      await runWithoutReductoInstrumentationAsync(() async {
        expect(reductoInstrumentationSuppressed(), isTrue);
      });
      expect(reductoInstrumentationSuppressed(), isFalse);
    });

    test('ReductoResult fields default null', () {
      const r = ReductoResult();
      expect(r.statusCode, isNull);
    });
  });
}
