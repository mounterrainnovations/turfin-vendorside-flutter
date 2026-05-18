// lib/core/network/alice_dio_interceptor.dart
//
// Bridges Dio's request/response lifecycle to Alice 1.0.0's addHttpCall API.
// Alice 1.0.0 removed the built-in getDioInterceptor() helper and moved to an
// adapter pattern — this interceptor is the equivalent hand-rolled bridge.

import 'dart:convert';
import 'package:alice/alice.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:dio/dio.dart';

class AliceDioInterceptor extends Interceptor {
  AliceDioInterceptor(this._alice);

  final Alice _alice;

  // Pending calls keyed by RequestOptions.hashCode, completed in onResponse/onError.
  final Map<int, AliceHttpCall> _pending = {};

  // ── Request ───────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final call = AliceHttpCall(options.hashCode)
      ..method   = options.method
      ..uri      = options.uri.toString()
      ..server   = options.uri.host
      ..endpoint = options.uri.path
      ..secure   = options.uri.scheme == 'https'
      ..client   = 'Dio';

    call.request = AliceHttpRequest()
      ..time            = DateTime.now()
      ..headers         = _stringifyHeaders(options.headers)
      ..queryParameters = options.queryParameters
      ..body            = options.data ?? ''
      ..contentType     = options.contentType
      ..size            = _byteSize(options.data);

    _pending[options.hashCode] = call;
    handler.next(options);
  }

  // ── Response ──────────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final call = _pending.remove(response.requestOptions.hashCode);
    if (call != null) {
      call
        ..loading  = false
        ..duration = _elapsed(call);

      call.response = AliceHttpResponse()
        ..status  = response.statusCode
        ..body    = response.data
        ..time    = DateTime.now()
        ..headers = _stringifyHeaderValues(response.headers.map)
        ..size    = _byteSize(response.data);

      _alice.addHttpCall(call);
    }
    handler.next(response);
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final call = _pending.remove(err.requestOptions.hashCode);
    if (call != null) {
      call
        ..loading  = false
        ..duration = _elapsed(call);

      if (err.response != null) {
        call.response = AliceHttpResponse()
          ..status  = err.response!.statusCode
          ..body    = err.response!.data
          ..time    = DateTime.now()
          ..headers = _stringifyHeaderValues(err.response!.headers.map)
          ..size    = _byteSize(err.response!.data);
      } else {
        // Network-level failure (no HTTP response at all)
        call.response = AliceHttpResponse()
          ..status = -1
          ..body   = err.message ?? 'Network error'
          ..time   = DateTime.now();
      }

      call.error = AliceHttpError()
        ..error      = err
        ..stackTrace = err.stackTrace;

      _alice.addHttpCall(call);
    }
    handler.next(err);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _elapsed(AliceHttpCall call) =>
      DateTime.now().difference(call.request!.time).inMilliseconds;

  int _byteSize(dynamic body) {
    if (body == null) return 0;
    if (body is String) return body.length;
    try { return jsonEncode(body).length; } catch (_) { return 0; }
  }

  Map<String, String> _stringifyHeaders(Map<String, dynamic> headers) =>
      headers.map((k, v) => MapEntry(k, v.toString()));

  Map<String, String> _stringifyHeaderValues(Map<String, List<String>> headers) =>
      headers.map((k, v) => MapEntry(k, v.join(', ')));
}
