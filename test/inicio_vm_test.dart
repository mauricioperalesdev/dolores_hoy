
import 'package:dolores_hoy/presentacion/inicio_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'ayudas.dart';

void main() {
  group('InicioVm - Dolores Hoy', () {
    test('carga correctamente las cinco APIs', () async {
      final vm = InicioVm(
        seguro(servidorFalso),
      );

      await vm.cargar(
        hoy: DateTime(2026, 11, 5),
      );

      expect(vm.cargando, false);
      expect(vm.error, isNull);

      // API 1: Clima
      expect(vm.clima?.temperatura, 24.3);

      // API 2: Tipo de cambio
      expect(vm.cambio, isNotNull);

      // API 3: Días festivos
      expect(vm.festivos, isNotEmpty);

      // API 4: Wikipedia
      expect(vm.wikipedia?.titulo, 'Dolores Hidalgo');

      // API 5: NASA
      expect(
        vm.nasa?.titulo,
        'Enceladus in Silhouette',
      );

      vm.dispose();
    });

    test('maneja errores sin cerrar la aplicación', () async {
      final vm = InicioVm(
        seguro((_) async => http.Response('', 500)),
      );

      await vm.cargar(
        hoy: DateTime(2026, 11, 5),
      );

      expect(vm.cargando, false);
      expect(vm.error, isNotNull);

      vm.dispose();
    });
  });
}
