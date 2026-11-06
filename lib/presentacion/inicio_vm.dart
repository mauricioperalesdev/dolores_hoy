
import 'package:flutter/foundation.dart';

import '../datos/cliente_seguro.dart';
import '../datos/servicios.dart';
import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';

class InicioVm extends ChangeNotifier {
  final ClienteSeguro _cliente;

  InicioVm(this._cliente);

  // Estado de la aplicación.
  bool cargando = false;
  String? error;

  // Información de las cinco APIs.
  Clima? clima;
  TipoCambio? cambio;
  List<Festivo> festivos = [];
  ResumenWiki? wikipedia;
  FotoAstronomica? nasa;

  // Cargar la información.
  Future<void> cargar({DateTime? hoy}) async {
    cargando = true;
    error = null;

    notifyListeners();

    try {
      // API 1: Clima
      clima = await ServicioClima(_cliente).actual();

      // API 2: Tipo de cambio
      cambio = await ServicioCambio(_cliente).deMxn();

      // API 3: Días festivos
      festivos = await ServicioFestivos(_cliente).proximos(
        hoy: hoy,
      );

      // API 4: Wikipedia
      wikipedia = await ServicioWikipedia(_cliente).resumen(
        'Dolores Hidalgo',
      );

      // API 5: NASA
      nasa = await ServicioNasa(_cliente).delDia();

    } catch (e) {
      // Mostrar un mensaje seguro si ocurre un error.
      error = mensajeSeguro(e);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
