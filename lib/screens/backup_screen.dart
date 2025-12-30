import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../services/backup_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
// Conditional import for different platforms
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

  String _formattedTimestamp() {
    return DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
  }

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Export on web - automatic download
        final jsonData = await _backupService.exportToJson();
        _downloadFile(
          jsonData,
          '${kFuelcalcFilePrefix}_backup_${_formattedTimestamp()}.json',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.backupDownloaded),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Export on mobile - message only for now
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.exportInDevelopment),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.exportError(e.toString()),
            ),
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

        // Debug: show first 200 characters of file
        debugPrint(
          'Import JSON preview: ${jsonString.substring(0, jsonString.length < 200 ? jsonString.length : 200)}...',
        );

        if (!_backupService.validateBackup(jsonString)) {
          throw Exception(AppLocalizations.of(context)!.invalidBackupFormat);
        }

        await _showConfirmationDialog(() async {
          await _backupService.importFromJson(jsonString);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.dataImportedSuccessfully,
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return to previous screen
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.importError(e.toString()),
            ),
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.sqliteExportNotAvailableOnWeb,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sqliteData = await _backupService.exportSqliteDatabase();

      if (sqliteData != null) {
        final fileName =
            '${kFuelcalcFilePrefix}_${_formattedTimestamp()}.sqlite';

        final savedPath = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['sqlite', 'db', 'sqlite3'],
          bytes: sqliteData,
        );

        if (savedPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.sqliteDatabaseExported,
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.sqliteExportError(e.toString()),
            ),
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.sqliteImportNotAvailableOnWeb,
          ),
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
          throw Exception(AppLocalizations.of(context)!.invalidSqliteFormat);
        }

        await _showSqliteConfirmationDialog(() async {
          await _backupService.importSqliteDatabase(sqliteData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.sqliteDatabaseImportedSuccessfully,
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return to previous screen
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.sqliteImportError(e.toString()),
            ),
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.confirmImport),
          content: Text(l10n.confirmImportMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(l10n.import),
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.confirmSqliteImport),
          content: Text(l10n.confirmSqliteImportMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.replaceDatabase),
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
              content: Text(
                AppLocalizations.of(context)!.fileDownloaded(fileName),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Fallback - show dialog with JSON
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return AlertDialog(
                title: Text(l10n.backupJson),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.automaticDownloadFailed),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      width: 500,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          content,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close),
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      // On mobile/desktop platforms - fallback for now
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.fileDownloadInDevelopment,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupManagement),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
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
                                Icon(
                                  Icons.backup,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.exportData,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.exportDataDescription,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _exportBackup,
                                icon: const Icon(Icons.download),
                                label: Text(l10n.exportDataButton),
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
                                Icon(
                                  Icons.restore,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.importData,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.importDataDescription,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _importBackup,
                                icon: const Icon(Icons.upload),
                                label: Text(l10n.importDataButton),
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

                    // SQLite Export
                    if (!kIsWeb)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storage,
                                    color: Colors.teal,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.exportSqliteDatabase,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.exportSqliteDescription,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _exportSqlite,
                                  icon: const Icon(Icons.download),
                                  label: Text(l10n.exportSqliteButton),
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

                    // SQLite Import
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
                                  Icon(
                                    Icons.input,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.importSqliteDatabase,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.importSqliteDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _importSqlite,
                                  icon: const Icon(Icons.upload),
                                  label: Text(l10n.importSqliteButton),
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
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.information,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.backupInformation,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
