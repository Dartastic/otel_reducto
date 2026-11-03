// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_reducto/otel_reducto.dart';

/// Traces Reducto calls with OpenTelemetry.
///
/// `otel_reducto` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Reducto call in
/// [tracedReducto]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'reducto-example');

  // Traces a Reducto call.
  final reductoId = await tracedReducto<String>(
    operation: 'create',
    invoke: () async {
      // Make the Reducto call here, then report what it returned.
      const id = 'reducto_8f3a2c';
      return const ReductoCallResult(
          value: id,
          result: ReductoResult(
              jobId: 'job_8f3a2c',
              fileName: 'example',
              fileSize: 512,
              pageCount: 3,
              chunkingStrategy: 'example',
              ocrEnabled: true,
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedReducto create returned $reductoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutReductoInstrumentationAsync.
  await runWithoutReductoInstrumentationAsync(
    () => tracedReducto<String>(
      operation: 'create',
      invoke: () async {
        const id = 'reducto_8f3a2c';
        return const ReductoCallResult(
            value: id,
            result: ReductoResult(
                jobId: 'job_8f3a2c',
                fileName: 'example',
                fileSize: 512,
                pageCount: 3,
                chunkingStrategy: 'example',
                ocrEnabled: true,
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
