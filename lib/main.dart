import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/repositories/storage_repository.dart';
import 'core/services/isar_service.dart';
import 'features/scanner/scanner_screen.dart';

late final StorageRepository storageRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
