import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'entrega_screen.dart';

class PaquetesScreen extends StatefulWidget {
  final int agenteId;
  final String nombre;
  const PaquetesScreen({super.key, required this.agenteId, required this.nombre});

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  List paquetes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarPaquetes();
  }

  Future<void> cargarPaquetes() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:8000/paquetes/${widget.agenteId}'),
      );
      if (res.statusCode == 200) {
        setState(() => paquetes = jsonDecode(res.body));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar paquetes')));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${widget.nombre}'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: cargarPaquetes)
        ],
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : paquetes.isEmpty
          ? const Center(child: Text('No tienes paquetes pendientes ✅'))
          : ListView.builder(
              itemCount: paquetes.length,
              itemBuilder: (context, i) {
                final p = paquetes[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2, color: Colors.deepOrange),
                    title: Text(p['codigo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p['destinatario']}\n${p['direccion_destino']}'),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EntregaScreen(
                          paqueteId: p['id'],
                          agenteId: widget.agenteId,
                          direccion: p['direccion_destino'],
                          codigo: p['codigo'],
                        ))).then((_) => cargarPaquetes()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                      child: const Text('Entregar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}