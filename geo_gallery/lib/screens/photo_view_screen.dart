import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travel_entry.dart';

/// Pantalla que muestra una foto a pantalla completa, con detalles y opción de eliminar
class PhotoViewScreen extends StatelessWidget {
  final TravelEntry entry; // Entrada del diario a mostrar

  const PhotoViewScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Formatea la fecha de la entrada para mostrarla en los  detalles
    final formattedDate = DateFormat.yMMMMd('es').add_jm().format(entry.date);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Muestra la imagen con animación (Hero) y posibilidad de hacer zoom
          Center(
            child: Hero(
              tag: entry.photoPath,
              child: InteractiveViewer(
                child: Image.file(File(entry.photoPath)),
              ),
            ),
          ),
          // Botón para cerrar la vista completa
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Botón para eliminar la entrada
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Eliminar',
              onPressed: () => _confirmDelete(context),
            ),
          ),
          // Botón inferior para ver los detalles del viaje
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  /// Muestra un diálogo de confirmación para eliminar la entrada
  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar entrada?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Eliminar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await entry.delete(); // Elimina la entrada del box de Hive
      try {
        File(entry.photoPath).deleteSync(); // Elimina el archivo de imagen local
      } catch (e) {
        print("Error al eliminar imagen: $e");
      }

      Navigator.pop(context); // Cierra la pantalla actual
    }
  }

  /// Muestra una hoja desplegable con los detalles del viaje
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
              _buildRow("📝 Comentario",
                  entry.comment.isNotEmpty ? entry.comment : "Sin comentario"),
              _buildRow("📅 Fecha", formattedDate),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Crea una fila de información dentro del panel de detalles
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
