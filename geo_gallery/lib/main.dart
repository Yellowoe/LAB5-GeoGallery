import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/travel_entry.dart';
import 'screens/gallery_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Función principal de la app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de cualquier código asíncrono

  // Solicita permisos de ubicación una vez al iniciar la app
  await requestLocationPermission();

  // Inicializa soporte para formato de fechas en español
  await initializeDateFormatting('es', null);

  // Obtiene directorio del dispositivo donde se guardarán los datos
  final appDir = await getApplicationDocumentsDirectory();

  // Inicializa Hive con la ruta local
  await Hive.initFlutter(appDir.path);

  // Registra el adaptador del modelo TravelEntry
  Hive.registerAdapter(TravelEntryAdapter());

  // Abre (o crea) la caja de datos llamada 'entries'
  await Hive.openBox<TravelEntry>('entries');

  // Inicia la aplicación
  runApp(const MyApp());
}

/// Funcion para solicitar permisos de ubicación
Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    await Permission.location.request();
  }
}

/// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoGallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GalleryScreen(), // Pantalla principal de la app
    );
  }
}
