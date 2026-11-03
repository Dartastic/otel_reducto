// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_reducto_suppression.dart';

class ReductoResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class ReductoCallResult<T> {
  /// Creates a call result.
  const ReductoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final ReductoResult? result;
}

Future<T> tracedReducto<T>({
  required String operation,
  required Future<ReductoCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (reductoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_reducto');
  final span = t.startSpan('reducto $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'reducto')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gen_ai.system', 'reducto')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('reducto.job.id', res.jobId!)]));
      }
      if (res.fileName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('file.name', res.fileName!)]));
      }
      if (res.fileSize != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('file.size', res.fileSize!)]));
      }
      if (res.pageCount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('reducto.page_count', res.pageCount!)]));
      }
      if (res.chunkingStrategy != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'reducto.chunking_strategy',
            res.chunkingStrategy!,
          )
        ]));
      }
      if (res.ocrEnabled != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeBool('reducto.ocr', res.ocrEnabled!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('reducto.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('reducto.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'reducto.error',
          )
        ]));
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
