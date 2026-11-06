
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dominio/excepciones.dart';

/// Cliente HTTP que utilizan las cinco APIs.
class ClienteSeguro {
  final http.Client _cliente;
  final Duration espera;
  final int maxBytes;

  ClienteSeguro(
    this._cliente, {
    this.espera = const Duration(seconds: 8),
    this.maxBytes = 1024 * 1024,
  });

  static const _cabeceras = {
    'Accept': 'application/json',
    'User-Agent': 'DoloresHoy/1.0 (curso Flutter UTNG)',
  };

  /// Obtener JSON mediante una conexión HTTPS.
  Future<dynamic> obtenerJson(Uri uri) async {
    if (uri.scheme != 'https') {
      throw const ConexionInseguraException();
    }

    http.Response r;

    try {
      r = await _cliente.get(
        uri,
        headers: _cabeceras,
      ).timeout(espera);
    } on SocketException {
      throw const SinConexionException();
    } on TimeoutException {
      throw const SinConexionException();
    } on http.ClientException {
      throw const SinConexionException();
    }

    // Verificar si el servidor respondió correctamente.
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ErrorServidorException(r.statusCode);
    }

    // Rechazar respuestas demasiado grandes.
    if (r.bodyBytes.length > maxBytes) {
      throw const RespuestaDemasiadoGrandeException();
    }

    // Convertir la respuesta a JSON.
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      throw const RespuestaInvalidaException();
    }
  }

  /// Ocultar claves de API en las URL utilizadas para registros.
  static String redactar(Uri uri) {
    const secretos = {
      'api_key',
      'apikey',
      'key',
      'token',
      'access_token',
    };

    final params = uri.queryParameters.map(
      (k, v) => MapEntry(
        k,
        secretos.contains(k.toLowerCase()) ? '***' : v,
      ),
    );

    if (params.isEmpty) {
      return uri.toString();
    }

    // Conservar los asteriscos visibles en los registros.
    final query = params.entries.map((e) {
      final clave = Uri.encodeQueryComponent(e.key);
      final valor = e.value == '***'
          ? '***'
          : Uri.encodeQueryComponent(e.value);

      return '$clave=$valor';
    }).join('&');

    return uri.replace(query: query).toString();
  }
}

/// Convertir JSON a objetos y manejar respuestas inválidas.
T convertir<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    throw const RespuestaInvalidaException();
  }
}
