import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travel_entry.dart';

// para formatear correctamente los datos en el formato
import 'package:intl/date_symbol_data_local.dart';

class PhotoViewScreen extends StatelessWidget {
  final TravelEntry entry;
  const PhotoViewScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    
    initializeDateFormatting('es', null); 
  final formattedDate = DateFormat.yMMMMd('es').add_jm().format(entry.date);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: entry.photoPath,
              child: InteractiveViewer(
                child: Image.file(File(entry.photoPath)),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.expand_less),
                label: const Text("Ver detalles"),
                onPressed: () =>
                    _showDetailsSheet(context, entry, formattedDate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsSheet(
      BuildContext context, TravelEntry entry, String formattedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Detalles del viaje",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRow("📍 Lugar", entry.locationName ?? "No disponible"),
              _buildRow("🌍 Coordenadas",
                  "Lat: ${entry.latitude.toStringAsFixed(4)}, Lng: ${entry.longitude.toStringAsFixed(4)}"),
              _buildRow("📝 Comentario", entry.comment),
              _buildRow("📅 Fecha", formattedDate),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
