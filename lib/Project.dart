import 'package:flutter/material.dart';

void main() {
  runApp(const MiappFinanazas());
}

class Transaccion {
  // 1. Atributos
  String id;
  String titulo;
  double monto;
  DateTime fecha;
  String tipoGasto; // Ejemplo: "Necesidad", "Lujo", "Inversión"

  // 2. Constructor
  Transaccion({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.fecha,
    required this.tipoGasto,
  });
}

class ingreso {
  // 1. Atributos
  String id;
  String titulo;
  double monto;
  DateTime fecha;
  String tipoIngreso; // Ejemplo: "Salario", "Inversión", "Regalo"

  // 2. Constructor
  ingreso({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.fecha,
    required this.tipoIngreso,
  });
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

  double totalGastos(List<Transaccion> listaGastos) {
    double total = 0;
    for (Transaccion t in listaGastos) {
      total += t.monto;
    }
    return total;
  }

  double totalIngresos(List<ingreso> listaIngresos) {
    double total = 0;
    for (ingreso i in listaIngresos) {
      total += i.monto;
    }
    return total;
  }

  double calcularBalance(double totalIngresos, double totalGastos) {
    return totalIngresos - totalGastos;
  }

  double calcularNecesidad(List<Transaccion> listaGastos) {
    double Necesidad = 0;
    for (Transaccion t in listaGastos) {
      if (t.tipoGasto == "Necesidad") {
        Necesidad += t.monto;
      }
    }
    return Necesidad;
  }

  double calcularLujo(List<Transaccion> listaGastos) {
    double Lujo = 0;
    for (Transaccion t in listaGastos) {
      if (t.tipoGasto == "Lujo") {
        Lujo += t.monto;
      }
    }
    return Lujo;
  }

  double calcularAhorro(List<Transaccion> listaGastos) {
    double ahorro = 0;
    for (Transaccion t in listaGastos) {
      if (t.tipoGasto == "Inversión") {
        ahorro += t.monto;
      }
    }
    return ahorro;
  }

  List<Transaccion> listaGastos = [];
  List<ingreso> listaIngresos = [];

  void agregarTransaccion() {
    double montoIngresado = double.tryParse(montoController.text) ?? 0.0;

    Transaccion nuevaTransaccion = Transaccion(
      id: DateTime.now().toString(),
      titulo: tituloController.text,
      monto: montoIngresado,
      fecha: DateTime.now(),
      tipoGasto: 'Necesidad',
    );

    setState(() {
      listaGastos.add(nuevaTransaccion);

      tituloController.clear();
      montoController.clear();
    });
  }

  void agregarIngreso() {
    double montoIngresado = double.tryParse(montoController.text) ?? 0.0;

    ingreso Miingreso = ingreso(
      id: DateTime.now().toString(),
      titulo: tituloController.text,
      monto: montoIngresado,
      fecha: DateTime.now(),
      tipoIngreso: 'Salario',
    );

    setState(() {
      listaIngresos.add(Miingreso);

      tituloController.clear();
      montoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Finanzas")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
              ),
            ),

            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
              ),
            ),

            ElevatedButton(
              onPressed: agregarTransaccion,
              child: Text('Agregar Transacción'),
            ),

            ElevatedButton(
              onPressed: agregarIngreso,
              child: Text('Agregar Ingreso'),
            ),
          ],
        ),
      ),
    );
  }
}
