import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/backup_service.dart';
// Warunkowy import dla różnych platform
import '../utils/web_download_helper_stub.dart'
    if (dart.library.html) '../utils/web_download_helper.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    
    try {
      if (kIsWeb) {
        // Eksport na web - automatyczne pobieranie
        final jsonData = await _backupService.exportToJson();
        _downloadFile(jsonData, 'fuelcalc_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup został pobrany'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Eksport na mobile - na razie tylko komunikat
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eksport na mobile - funkcja w rozwoju'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd eksportu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _importBackup() async {
    setState(() => _isLoading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final jsonString = String.fromCharCodes(result.files.first.bytes!);
        
        if (!_backupService.validateBackup(jsonString)) {
          throw Exception('Nieprawidłowy format pliku backup');
        }

        await _showConfirmationDialog(() async {
          await _backupService.importFromJson(jsonString);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dane zostały zaimportowane pomyślnie'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Wróć do poprzedniego ekranu
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd importu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _exportSqlite() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eksport SQLite nie jest dostępny na web'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final sqliteData = await _backupService.exportSqliteDatabase();
      
      if (sqliteData != null) {
        // Na desktop - pokaż dane w dialogu (docelowo save file dialog)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Baza SQLite została wyeksportowana'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd eksportu SQLite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _importSqlite() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import SQLite nie jest dostępny na web'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite', 'sqlite3'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final sqliteData = result.files.first.bytes!;
        
        if (!_backupService.validateSqliteFile(sqliteData)) {
          throw Exception('Nieprawidłowy format pliku SQLite');
        }

        await _showSqliteConfirmationDialog(() async {
          await _backupService.importSqliteDatabase(sqliteData);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Baza SQLite została zaimportowana pomyślnie'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Wróć do poprzedniego ekranu
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd importu SQLite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _showConfirmationDialog(VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdź import'),
          content: const Text(
            'Import danych z backup może nadpisać istniejące dane. '
            'Czy chcesz kontynuować?'
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Importuj'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSqliteConfirmationDialog(VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdź import SQLite'),
          content: const Text(
            'Import pliku SQLite zastąpi całą istniejącą bazę danych. '
            'Ta operacja nie może być cofnięta. '
            'Czy chcesz kontynuować?'
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('ZASTĄP BAZĘ'),
            ),
          ],
        );
      },
    );
  }

  void _downloadFile(String content, String fileName) {
    if (kIsWeb) {
      try {
        WebDownloadHelper.downloadFile(content, fileName);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plik $fileName został pobrany'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Fallback - pokaż dialog z JSON
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Backup JSON'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Automatyczne pobieranie nie powiodło się. Skopiuj dane poniżej:'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    width: 500,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        content,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zamknij'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      // Na platformach mobilnych/desktop - na razie fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pobieranie plików na tej platformie w rozwoju'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzanie Backup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.backup, color: Colors.green, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Eksport danych',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Utwórz kopię zapasową wszystkich danych aplikacji '
                            '(samochody, tankowania, wydatki).',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _exportBackup,
                              icon: const Icon(Icons.download),
                              label: const Text('Eksportuj dane'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restore, color: Colors.orange, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Import danych',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Wczytaj dane z pliku backup. Uwaga: może to nadpisać '
                            'istniejące dane.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _importBackup,
                              icon: const Icon(Icons.upload),
                              label: const Text('Importuj dane'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Eksport SQLite
                  if (!kIsWeb) 
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.storage, color: Colors.teal, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Eksport bazy SQLite',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Eksportuj oryginalny plik bazy danych SQLite. '
                              'Można go otworzyć w innych aplikacjach SQLite.',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _exportSqlite,
                                icon: const Icon(Icons.download),
                                label: const Text('Eksportuj SQLite'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Import SQLite
                  if (!kIsWeb) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.input, color: Colors.red, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Import bazy SQLite',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Wczytaj plik bazy SQLite. UWAGA: zastąpi to całą '
                              'istniejącą bazę danych!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _importSqlite,
                                icon: const Icon(Icons.upload),
                                label: const Text('Importuj SQLite'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Informacje',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '• Backup JSON: uniwersalny format, działa na wszystkich platformach\n'
                            '• Backup SQLite: oryginalny plik bazy, tylko na desktop/mobile\n'
                            '• Oba formaty zawierają wszystkie dane\n'
                            '• SQLite można otworzyć w zewnętrznych narzędziach\n'
                            '• Import może nadpisać istniejące dane',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

