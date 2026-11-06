
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datos/cliente_seguro.dart';
import 'dominio/modelos.dart';
import 'presentacion/inicio_vm.dart';

void main() {
  runApp(const DoloresHoyApp());
}

class DoloresHoyApp extends StatelessWidget {
  const DoloresHoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dolores Hoy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      ),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late final http.Client clienteHttp;
  late final InicioVm vm;

  @override
  void initState() {
    super.initState();

    clienteHttp = http.Client();
    vm = InicioVm(ClienteSeguro(clienteHttp));

    vm.cargar();
  }

  @override
  void dispose() {
    vm.dispose();
    clienteHttp.close();
    super.dispose();
  }

  Widget tarjeta({
    required String titulo,
    required IconData icono,
    required Widget contenido,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icono,
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            contenido,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Dolores Hoy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => vm.cargar(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => vm.cargar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '¡Bienvenido a Dolores Hoy!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Información útil en un solo lugar.',
                ),
                const SizedBox(height: 20),

                if (vm.cargando)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (vm.error != null)
                  tarjeta(
                    titulo: 'Ocurrió un problema',
                    icono: Icons.warning_amber,
                    contenido: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vm.error!),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => vm.cargar(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),

                tarjeta(
                  titulo: 'Clima en Dolores Hidalgo',
                  icono: Icons.cloud,
                  contenido: vm.clima == null
                      ? const Text('Sin datos del clima.')
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${describirClima(vm.clima!.codigo).$1} '
                              '${vm.clima!.temperatura.toStringAsFixed(1)} °C',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              describirClima(vm.clima!.codigo).$2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Humedad: ${vm.clima!.humedad}%',
                            ),
                            Text(
                              'Viento: ${vm.clima!.viento} km/h',
                            ),
                          ],
                        ),
                ),

                tarjeta(
                  titulo: 'Tipo de cambio',
                  icono: Icons.currency_exchange,
                  contenido: vm.cambio == null
                      ? const Text('Sin datos de divisas.')
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1 USD = '
                              '\$${vm.cambio!.pesosPorUnidad('USD').toStringAsFixed(2)} MXN',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1 EUR = '
                              '\$${vm.cambio!.pesosPorUnidad('EUR').toStringAsFixed(2)} MXN',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                ),

                tarjeta(
                  titulo: 'Próximos días festivos',
                  icono: Icons.calendar_month,
                  contenido: vm.festivos.isEmpty
                      ? const Text(
                          'No hay días festivos próximos disponibles.',
                        )
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: vm.festivos.map((f) {
                            final fecha =
                                '${f.fecha.day}/${f.fecha.month}/${f.fecha.year}';

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: Text(
                                '📅 $fecha — ${f.nombre}',
                              ),
                            );
                          }).toList(),
                        ),
                ),

                tarjeta(
                  titulo: 'Conoce Dolores Hidalgo',
                  icono: Icons.menu_book,
                  contenido: vm.wikipedia == null
                      ? const Text(
                          'Sin información de Wikipedia.',
                        )
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.wikipedia!.titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (vm.wikipedia!.urlImagen != null)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Image.network(
                                  vm.wikipedia!.urlImagen!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stack) =>
                                          const SizedBox.shrink(),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(vm.wikipedia!.extracto),
                          ],
                        ),
                ),

                tarjeta(
                  titulo: 'NASA: Imagen astronómica',
                  icono: Icons.auto_awesome,
                  contenido: vm.nasa == null
                      ? const Text(
                          'Sin información de NASA.',
                        )
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.nasa!.titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (vm.nasa!.urlImagen != null)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Image.network(
                                  vm.nasa!.urlImagen!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stack) =>
                                          const Text(
                                    'No se pudo cargar la imagen.',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(vm.nasa!.explicacion),
                          ],
                        ),
                ),

                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Dolores Hoy • Proyecto Flutter',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
