
import '../dominio/excepciones.dart';

/// Configuración de claves para las APIs.
class ConfigClaves {
  final String nasa;

  const ConfigClaves({
    required this.nasa,
  });

  /// Lee la clave al compilar la aplicación.
  factory ConfigClaves.desdeEntorno() =>
      const ConfigClaves(
        nasa: String.fromEnvironment(
          'NASA_API_KEY',
          defaultValue: 'DEMO_KEY',
        ),
      );

  bool get usaClaveDemo => nasa == 'DEMO_KEY';

  /// Verifica que la clave no esté vacía.
  void validar() {
    if (nasa.trim().isEmpty) {
      throw const ClaveFaltanteException('NASA_API_KEY');
    }
  }

  /// Evita mostrar la clave completa.
  @override
  String toString() =>
      'ConfigClaves(nasa: ${_ocultar(nasa)})';

  static String _ocultar(String s) =>
      s.length <= 4
          ? '****'
          : '${s.substring(0, 2)}***${s.substring(s.length - 2)}';
}
