// models/travel_entry.dart

import 'package:hive/hive.dart';

part 'travel_entry.g.dart'; // Este archivo se genera automáticamente

@HiveType(typeId: 0)
class TravelEntry extends HiveObject {
  @HiveField(0)
  String photoPath; // Ruta local de la imagen

  @HiveField(1)
  String comment; // Comentario del usuario

  @HiveField(2)
  DateTime date; // Fecha de la entrada

  @HiveField(3)
  double latitude; // Latitud GPS

  @HiveField(4)
  double longitude; // Longitud GPS

  @HiveField(5)
  String? locationName; //  nombre del lugar si lo extraes

  TravelEntry({
    required this.photoPath,
    required this.comment,
    required this.date,
    required this.latitude,
    required this.longitude,
    this.locationName,
  });
}
