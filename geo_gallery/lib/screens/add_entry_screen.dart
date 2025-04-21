import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/travel_entry.dart';
import 'package:geocoding/geocoding.dart';

/// Pantalla para agregar una nueva entrada del diario de viaje
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  File? _imageFile;               // Imagen seleccionada o capturada
  Position? _position;            // Posición GPS obtenida
  String? _locationName;          // Nombre del lugar (ciudad, país)

  final TextEditingController _commentController = TextEditingController();

  /// Función para tomar una foto con la cámara
  /// y luego obtener la ubicación automáticamente
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

      setState(() {
        _imageFile = savedImage;
      });

      await _getLocation(); // Captura la ubicación automáticamente
    }
  }

  /// Función para obtener la ubicación GPS y convertirla en nombre de lugar
  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
      String country = place.country ?? '';

      setState(() {
        _position = position;
        _locationName = city.isNotEmpty ? "$city, $country" : country;
      });
    } catch (e) {
      print("Error obteniendo ubicación: $e");
    }
  }

  /// Función para guardar una nueva entrada en Hive
  Future<void> _saveEntry() async {
    if (_imageFile == null || _position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe tomar una foto primero')),
      );
      return;
    }

    final box = Hive.box<TravelEntry>('entries');
    final newEntry = TravelEntry(
      photoPath: _imageFile!.path,
      comment: _commentController.text,
      date: DateTime.now(),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      locationName: _locationName,
    );

    await box.add(newEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📍 Entrada guardada exitosamente')),
    );

    Navigator.pop(context, true); // Volver a la pantalla anterior
  }

  /// Construcción del layout de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva entrada')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botón para tomar foto (o mostrar la imagen si ya se tomó)
              _imageFile == null
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt, size: 28),
                      label: const Text("Tomar foto"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _getImage,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

              const SizedBox(height: 20),

              // Mostrar ubicación si ya está disponible
              if (_locationName != null)
                Text(
                  "📍 $_locationName",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),

              const SizedBox(height: 20),

              // Campo de texto para comentario (opcional)
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Comentario (opcional)",
                  hintText: "¿Qué estás recordando?",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botón para guardar la entrada
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar entrada"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _saveEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
