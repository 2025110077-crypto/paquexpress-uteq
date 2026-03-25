import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';

class EntregaScreen extends StatefulWidget {
  final int paqueteId;
  final int agenteId;
  final String direccion;
  final String codigo;
  const EntregaScreen({super.key, required this.paqueteId, required this.agenteId, required this.direccion, required this.codigo});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  Uint8List? fotoBytes;
  String? fotoNombre;
  Position? posicion;
  bool loading = false;

  Future<void> tomarFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() { fotoBytes = bytes; fotoNombre = img.name; });
    }
  }

  Future<void> obtenerGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa el GPS del dispositivo')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() => posicion = pos);
  }

  Future<void> registrarEntrega() async {
    if (fotoBytes == null || posicion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necesitas foto y ubicación GPS')));
      return;
    }
    setState(() => loading = true);
    try {
      final req = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/entregas/registrar'));
      req.fields['paquete_id'] = widget.paqueteId.toString();
      req.fields['agente_id'] = widget.agenteId.toString();
      req.fields['latitud'] = posicion!.latitude.toString();
      req.fields['longitud'] = posicion!.longitude.toString();
      req.files.add(http.MultipartFile.fromBytes('foto', fotoBytes!, filename: fotoNombre ?? 'foto.jpg'));
      final res = await req.send();
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Entrega registrada exitosamente! ✅')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar entrega')));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregar ${widget.codigo}'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mapa
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('📍 Dirección de entrega', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 200,
                    child: posicion != null
                      ? FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(posicion!.latitude, posicion!.longitude),
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(posicion!.latitude, posicion!.longitude),
                                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                              )
                            ]),
                          ],
                        )
                      : Center(child: Text(widget.direccion, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Foto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (fotoBytes != null)
                      Image.memory(fotoBytes!, height: 150, fit: BoxFit.cover)
                    else
                      const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: tomarFoto,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Seleccionar foto'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GPS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    posicion != null
                      ? Text('✅ GPS: ${posicion!.latitude.toStringAsFixed(5)}, ${posicion!.longitude.toStringAsFixed(5)}')
                      : const Text('❌ Sin ubicación GPS'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: obtenerGPS,
                      icon: const Icon(Icons.gps_fixed),
                      label: const Text('Obtener ubicación'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón entregar
            ElevatedButton.icon(
              onPressed: loading ? null : registrarEntrega,
              icon: const Icon(Icons.check_circle),
              label: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('📦 Paquete Entregado', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}