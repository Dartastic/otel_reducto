// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_reducto_suppression.dart';

class ReductoResult {
  const ReductoResult({
    this.jobId,
    this.fileName,
    this.fileSize,
    this.pageCount,
    this.chunkingStrategy,
    this.ocrEnabled,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? jobId;
  final String? fileName;
  final int? fileSize;
  final int? pageCount;
  final String? chunkingStrategy;
  final bool? ocrEnabled;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class ReductoCallResult<T> {
  const ReductoCallResult({required this.value, this.result});
  final T value;
  final ReductoResult? result;
}

Future<T> tracedReducto<T>({
  required String operation,
  required Future<ReductoCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (reductoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_reducto');
  final span = t.startSpan('reducto $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'reducto');
    span.setStringAttribute('gen_ai.system', 'reducto');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.jobId != null) {
        span.setStringAttribute('reducto.job.id', res.jobId!);
      }
      if (res.fileName != null) {
        span.setStringAttribute('file.name', res.fileName!);
      }
      if (res.fileSize != null) {
        span.setIntAttribute('file.size', res.fileSize!);
      }
      if (res.pageCount != null) {
        span.setIntAttribute('reducto.page_count', res.pageCount!);
      }
      if (res.chunkingStrategy != null) {
        span.setStringAttribute(
          'reducto.chunking_strategy',
          res.chunkingStrategy!,
        );
      }
      if (res.ocrEnabled != null) {
        span.setBoolAttribute('reducto.ocr', res.ocrEnabled!);
      }
      if (res.durationMs != null) {
        span.setIntAttribute('reducto.duration', res.durationMs!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('reducto.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'reducto.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
