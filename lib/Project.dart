import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiappFinanazas());
}

enum TipoMovimiento { gasto, ingreso }

enum TipoGasto { necesidad, lujo, ahorro }

enum TipoIngreso { arriendo, cosas, otro }

enum TipoDivisa { USD, COP, ARS }

class ServicioMovimiento {
  static const String _keyMovimientos = 'lista_movimientos_key';

  static Future<void> guardarMovimientos(
    List<Movimiento> listaMovimientos,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> listaJson = listaMovimientos
        .map((movimiento) => jsonEncode(movimiento.toMap()))
        .toList();

    await prefs.setStringList(_keyMovimientos, listaJson);
  }

  static Future<List<Movimiento>> cargarMovimientos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? listaJson = prefs.getStringList(_keyMovimientos);

    if (listaJson == null) {
      return [];
    }

    return listaJson.map((textoJson) {
      final Map<String, dynamic> mapa = jsonDecode(textoJson);
      return Movimiento.fromMap(mapa);
    }).toList();
  }
}

class Movimiento {
  // 1. Atributos
  String id;
  String titulo;
  double monto;
  DateTime fecha;
  DateTime hora;
  TipoMovimiento tipoMovimiento;
  TipoDivisa divisa;

  // 2. Constructor
  Movimiento({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.fecha,
    required this.hora,
    required this.tipoMovimiento,
    required this.divisa,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "monto": monto,
      "fecha": fecha.toIso8601String(),
      "hora": hora.toIso8601String(),
      "tipoMovimiento": tipoMovimiento.name,
      "tipoDivisa": divisa.name,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map["id"] as String,
      titulo: map["titulo"] as String,
      monto: (map["monto"] as num).toDouble(),
      fecha: DateTime.parse(map["fecha"] as String),
      hora: DateTime.parse(map["hora"] as String),
      tipoMovimiento: TipoMovimiento.values.byName(
        map["tipoMovimiento"] as String,
      ),
      divisa: TipoDivisa.values.byName(map["tipoDivisa"] as String),
    );
  }
}

class MiappFinanazas extends StatelessWidget {
  const MiappFinanazas({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Gestión de Finanzas', home: PantallaFinanzas());
  }
}

class PantallaFinanzas extends StatefulWidget {
  const PantallaFinanzas({super.key, this.title = 'Finanzas'});
  final String title;

  @override
  State<PantallaFinanzas> createState() => _PantallaFinanzasState();
}

class _PantallaFinanzasState extends State<PantallaFinanzas> {
  final tituloController = TextEditingController();
  final montoController = TextEditingController();
  late double total;

  TipoMovimiento tipoSeleccionado = TipoMovimiento.ingreso;
  TipoDivisa divisaSeleccionada = TipoDivisa.USD;

  List<Movimiento> listaMovimientos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    final datosCargados = await ServicioMovimiento.cargarMovimientos();

    setState(() {
      listaMovimientos = datosCargados;
    });
  }

  double convertirAUSD(double montolocal, TipoDivisa divisa) {
    switch (divisa) {
      case TipoDivisa.USD:
        return montolocal;
      case TipoDivisa.COP:
        return montolocal * 0.00033; // Ejemplo de tasa de cambio
      case TipoDivisa.ARS:
        return montolocal * 0.00067; // Ejemplo de tasa de cambio
    }
  }

  double calcularTotal() {
    double totalIngresos = listaMovimientos
        .where((mov) => mov.tipoMovimiento == TipoMovimiento.ingreso)
        .fold(0.0, (sum, mov) => sum + mov.monto);

    double totalGastos = listaMovimientos
        .where((mov) => mov.tipoMovimiento == TipoMovimiento.gasto)
        .fold(0.0, (sum, mov) => sum + mov.monto);

    return totalIngresos - totalGastos;
  }

  double calcularTotalIngresos() {
    return listaMovimientos
        .where((mov) => mov.tipoMovimiento == TipoMovimiento.ingreso)
        .fold(0.0, (sum, mov) => sum + mov.monto);
  }

  double calcularTotalGastos() {
    return listaMovimientos
        .where((mov) => mov.tipoMovimiento == TipoMovimiento.gasto)
        .fold(0.0, (sum, mov) => sum + mov.monto);
  }

  void agregarMovimiento() {
    double montoIngresado = double.tryParse(montoController.text) ?? 0.0;

    Movimiento nuevoMovimiento = Movimiento(
      id: DateTime.now().toString(),
      titulo: tituloController.text,
      monto: convertirAUSD(montoIngresado, divisaSeleccionada),
      fecha: DateTime.now(),
      hora: DateTime.now(),
      tipoMovimiento: tipoSeleccionado,
      divisa: divisaSeleccionada,
    );

    setState(() {
      listaMovimientos.insert(0, nuevoMovimiento);
      total = calcularTotal();
      tituloController.clear();
      montoController.clear();
    });
    ServicioMovimiento.guardarMovimientos(listaMovimientos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Finanzas")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Resumen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Ingresos:'),
                        Text(
                          "\$${calcularTotalIngresos().toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Gastos:'),
                        Text(
                          "\$${calcularTotalGastos().toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Balance Neto:'),
                        Text(
                          "\$${calcularTotal().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: calcularTotal() >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Nuevo Movimiento:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.all(8.0),
              child: TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.all(8.0),
              child: TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Tipo de Movimiento:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: DropdownButton<TipoMovimiento>(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      isExpanded: true,
                      value: tipoSeleccionado,
                      onChanged: (TipoMovimiento? nuevoTipo) {
                        setState(() {
                          tipoSeleccionado = nuevoTipo!;
                        });
                      },
                      items: TipoMovimiento.values.map((TipoMovimiento tipo) {
                        return DropdownMenuItem<TipoMovimiento>(
                          value: tipo,
                          child: Text(
                            tipo == TipoMovimiento.ingreso
                                ? 'Ingreso'
                                : 'Gasto',
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Divisa:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: DropdownButton<TipoDivisa>(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      isExpanded: true,
                      value: divisaSeleccionada,
                      onChanged: (TipoDivisa? nuevaDivisa) {
                        setState(() {
                          divisaSeleccionada = nuevaDivisa!;
                        });
                      },
                      items: TipoDivisa.values.map((TipoDivisa divisa) {
                        return DropdownMenuItem<TipoDivisa>(
                          value: divisa,
                          child: Text(
                            divisa == TipoDivisa.USD
                                ? 'USD'
                                : divisa == TipoDivisa.COP
                                ? 'COP'
                                : 'ARS',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tipoSeleccionado == TipoMovimiento.ingreso
                    ? const Color.fromARGB(255, 79, 134, 81)
                    : const Color.fromARGB(255, 134, 33, 26),
                side: BorderSide(color: Colors.black, width: 2.0),
              ),
              onPressed: () => agregarMovimiento(),
              child: Text(
                tipoSeleccionado == TipoMovimiento.ingreso
                    ? 'Agregar Ingreso'
                    : 'Agregar Gasto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Historial de Movimientos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listaMovimientos.length,
                itemBuilder: (context, index) {
                  final movimiento = listaMovimientos[index];
                  return Dismissible(
                    key: Key(movimiento.id),

                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.black),
                    ),

                    direction: DismissDirection.endToStart,

                    onDismissed: (direction) {
                      final elementoEliminado = listaMovimientos[index];
                      final posicionOriginal = index;

                      setState(() {
                        listaMovimientos.removeAt(index);
                      });
                      ServicioMovimiento.guardarMovimientos(listaMovimientos);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Elemento eliminado'),
                          action: SnackBarAction(
                            label: 'DESHACER',
                            onPressed: () {
                              setState(() {
                                listaMovimientos.insert(
                                  posicionOriginal,
                                  elementoEliminado,
                                );
                              });
                              ServicioMovimiento.guardarMovimientos(
                                listaMovimientos,
                              );
                            },
                          ),
                        ),
                      );
                    },

                    child: ListTile(
                      leading: Icon(
                        movimiento.tipoMovimiento == TipoMovimiento.ingreso
                            ? Icons.add
                            : Icons.remove,
                        color:
                            movimiento.tipoMovimiento == TipoMovimiento.ingreso
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(movimiento.titulo),
                      subtitle: Text(
                        '${movimiento.fecha.toLocal().toString().split(' ')[0]} - '
                        '${movimiento.hora.hour.toString().padLeft(2, '0')}:'
                        '${movimiento.hora.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${movimiento.monto.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  movimiento.tipoMovimiento ==
                                      TipoMovimiento.ingreso
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ], // children
                      ),
                    ),
                  );
                }, // itemBuilder
              ),
            ),
          ], // children grande
        ),
      ),
    );
  } // build
}
