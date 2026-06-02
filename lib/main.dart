import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/repositories/storage_repository.dart';
import 'core/services/isar_service.dart';
import 'features/scanner/scanner_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

late final StorageRepository storageRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
    debug: true, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

  final isarService = IsarService();
  storageRepository = LocalStorageRepository(isarService);
  await storageRepository.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ScannerScreen());
  }
}
