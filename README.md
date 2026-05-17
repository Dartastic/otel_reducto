# otel_reducto

Dartastic OpenTelemetry bridge for Reducto (LLM-native document parsing).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_reducto/otel_reducto.dart';

await tracedReducto<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return ReductoCallResult(value: r, result: ReductoResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutReductoInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
