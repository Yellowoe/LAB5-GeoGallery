import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/travel_entry.dart';
import 'package:geocoding/geocoding.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  File? _imageFile;
  Position? _position;
  String? _locationName;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _position = position;
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      String city = place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          '';
      String country = place.country ?? '';

      setState(() {
        _locationName = city.isNotEmpty ? "$city, $country" : country;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_imageFile == null ||
        _position == null ||
        !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta imagen, ubicación o comentario')),
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

    Navigator.pop(context, true); // ← Volver al home y actualizar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva entrada')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _imageFile == null
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Tomar foto"),
                      onPressed: _getImage,
                    )
                  : Image.file(_imageFile!, height: 200),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text("Obtener ubicación"),
                onPressed: _getLocation,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: "Comentario",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Escribe algo' : null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar entrada"),
                onPressed: _saveEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
