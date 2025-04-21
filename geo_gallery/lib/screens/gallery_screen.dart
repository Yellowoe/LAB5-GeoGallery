import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/travel_entry.dart';
import 'add_entry_screen.dart';
import 'photo_view_screen.dart';

/// Modo de visualización disponible: Mosaico o agrupado por ubicación
enum ViewMode {
  grid,
  byLocation,
}

/// Mapa que asocia cada modo con un texto y un ícono
final Map<ViewMode, (String, IconData)> viewModeOptions = {
  ViewMode.grid: ('Mosaico', Icons.grid_view),
  ViewMode.byLocation: ('Ubicacion', Icons.location_on),
};

/// Pantalla principal que muestra la galería de fotos
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  ViewMode _viewMode = ViewMode.grid; // Modo de vista seleccionado

  @override
  Widget build(BuildContext context) {
    // Obtener la caja de entradas de Hive
    final box = Hive.box<TravelEntry>('entries');
    final entries = box.values.toList().reversed.toList(); // Mostrar las más recientes primero

    // Agrupar entradas por nombre de ubicación
    final entriesByLocation = <String, List<TravelEntry>>{};
    for (var entry in entries) {
      final key = entry.locationName ?? 'Ubicación desconocida';
      entriesByLocation.putIfAbsent(key, () => []).add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoGallery'),
        actions: [
          // Menú desplegable para cambiar el modo de vista
          Padding(
            padding: const EdgeInsets.only(right: 0, bottom: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ViewMode>(
                value: _viewMode,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (value) {
                  if (value != null) setState(() => _viewMode = value);
                },
                items: viewModeOptions.entries.map((entry) {
                  return DropdownMenuItem<ViewMode>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value.$2, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(entry.value.$1),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),

      // Mostrar las fotos segun el modo de vista seleccionado
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: entries.isEmpty
            ? const Center(child: Text("No hay fotos aún."))
            : _viewMode == ViewMode.grid
                ? _buildGrid(entries)
                : _buildGroupedByLocation(entriesByLocation),
      ),

      // Botón para agregar una nueva entrada
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
          if (result == true) setState(() {}); // Recargar si se agrega una entrada
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Muestra las fotos en formato de grilla
  Widget _buildGrid(List<TravelEntry> entries) {
    return GridView.builder(
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return GestureDetector(
          onTap: () => _openPhoto(entry), // Abrir la foto
          child: Hero(
            tag: entry.photoPath,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(entry.photoPath), fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  /// Muestra las fotos agrupadas por lugar
  Widget _buildGroupedByLocation(Map<String, List<TravelEntry>> grouped) {
    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con el nombre del lugar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Lista horizontal de fotos tomadas en ese lugar
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photo = entry.value[index];
                  return GestureDetector(
                    onTap: () => _openPhoto(photo),
                    child: Hero(
                      tag: photo.photoPath,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(photo.photoPath), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  /// Navegar a la pantalla que muestra la foto completa
  void _openPhoto(TravelEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewScreen(entry: entry),
      ),
    ).then((_) => setState(() {})); // Recargar la galería al volver
  }
}
