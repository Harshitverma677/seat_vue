import 'dart:convert';
import 'dart:io';
import 'package:http2/http2.dart';

/// Lightweight HTTP/2 client specialized for TMDB API communication.
/// Handles Happy Eyeballs / IPv6 prioritization because CloudFront IPv4 endpoints
/// are dropped/reset on some regional ISPs.
class TmdbHttpClient {
  ClientTransportConnection? _connection;
  String? _currentHost;
  int? _currentPort;

  Future<ClientTransportConnection> _getConnection(String host, int port) async {
    if (_connection != null && _connection!.isOpen && _currentHost == host && _currentPort == port) {
      return _connection!;
    }

    final addresses = await InternetAddress.lookup(host);
    // Prioritize IPv6 addresses as Cloudfront resets IPv4 on certain networks
    addresses.sort((a, b) {
      if (a.type == InternetAddressType.IPv6 && b.type != InternetAddressType.IPv6) return -1;
      if (b.type == InternetAddressType.IPv6 && a.type != InternetAddressType.IPv6) return 1;
      return 0;
    });

    for (final addr in addresses) {
      try {
        final socket = await SecureSocket.connect(
          addr,
          port,
          supportedProtocols: ['h2'],
          timeout: const Duration(seconds: 4),
          onBadCertificate: (_) => true,
        );
        _currentHost = host;
        _currentPort = port;
        _connection = ClientTransportConnection.viaSocket(socket);
        return _connection!;
      } catch (_) {
        continue;
      }
    }

    // Fallback directly to host name if address loop didn't connect
    final fallbackSocket = await SecureSocket.connect(
      host,
      port,
      supportedProtocols: ['h2'],
      timeout: const Duration(seconds: 6),
    );
    _currentHost = host;
    _currentPort = port;
    _connection = ClientTransportConnection.viaSocket(fallbackSocket);
    return _connection!;
  }

  Future<TmdbHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithRetry('GET', uri, headers: headers, timeout: timeout);
  }

  Future<TmdbHttpResponse> _sendWithRetry(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      return await _send(method, uri, headers: headers, timeout: timeout);
    } catch (_) {
      // Re-establish connection on drop and retry once
      _connection?.finish();
      _connection = null;
      return await _send(method, uri, headers: headers, timeout: timeout);
    }
  }

  Future<TmdbHttpResponse> _send(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final connection = await _getConnection(uri.host, uri.port == 0 ? 443 : uri.port);

    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    final requestHeaders = [
      Header.ascii(':method', method),
      Header.ascii(':path', path),
      Header.ascii(':scheme', uri.scheme.isEmpty ? 'https' : uri.scheme),
      Header.ascii(':authority', uri.host),
    ];

    if (headers != null) {
      for (final entry in headers.entries) {
        requestHeaders.add(Header.ascii(entry.key.toLowerCase(), entry.value));
      }
    }

    final stream = connection.makeRequest(requestHeaders, endStream: true);
    final chunks = <int>[];
    int statusCode = 500;
    final responseHeaders = <String, String>{};

    final future = () async {
      await for (final message in stream.incomingMessages) {
        if (message is HeadersStreamMessage) {
          for (final header in message.headers) {
            final name = utf8.decode(header.name);
            final value = utf8.decode(header.value);
            if (name == ':status') {
              statusCode = int.tryParse(value) ?? 500;
            } else {
              responseHeaders[name] = value;
            }
          }
        } else if (message is DataStreamMessage) {
          chunks.addAll(message.bytes);
        }
      }
      final body = utf8.decode(chunks);
      return TmdbHttpResponse(
        statusCode: statusCode,
        body: body,
        headers: responseHeaders,
      );
    }();

    return future.timeout(timeout, onTimeout: () {
      _connection?.finish();
      _connection = null;
      throw SocketException('Request to ${uri.host} timed out after ${timeout.inSeconds}s');
    });
  }

  void close() {
    _connection?.finish();
    _connection = null;
  }
}

class TmdbHttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  const TmdbHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
