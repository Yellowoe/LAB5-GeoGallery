import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/travel_entry.dart';
import 'add_entry_screen.dart';
import 'photo_view_screen.dart';

enum ViewMode {
  grid,
  byLocation,
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  ViewMode _viewMode = ViewMode.grid;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TravelEntry>('entries');
    final entries = box.values.toList().reversed.toList();

    final entriesByLocation = <String, List<TravelEntry>>{};
    for (var entry in entries) {
      final key = entry.locationName ?? 'Ubicación desconocida';
      entriesByLocation.putIfAbsent(key, () => []).add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario de Viaje'),
        centerTitle: true,
        actions: [
          DropdownButton<ViewMode>(
            value: _viewMode,
            onChanged: (value) {
              if (value != null) setState(() => _viewMode = value);
            },
            items: const [
              DropdownMenuItem(
                value: ViewMode.grid,
                child: Text('Mosaico'),
              ),
              DropdownMenuItem(
                value: ViewMode.byLocation,
                child: Text('Por ubicación'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: entries.isEmpty
            ? const Center(child: Text("No hay fotos aún."))
            : _viewMode == ViewMode.grid
                ? _buildGrid(entries)
                : _buildGroupedByLocation(entriesByLocation),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

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
          onTap: () => _openPhoto(entry),
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

  Widget _buildGroupedByLocation(Map<String, List<TravelEntry>> grouped) {
    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
                        child: Image.file(File(photo.photoPath),
                            fit: BoxFit.cover),
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

  void _openPhoto(TravelEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewScreen(entry: entry),
      ),
    ).then((_) => setState(() {}));
  }
}