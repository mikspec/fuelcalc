import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Sign in to Google account
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      _currentUser = account;

      // Get authenticated HTTP client
      final authenticatedClient = await _googleSignIn.authenticatedClient();
      if (authenticatedClient == null) {
        return false;
      }

      _driveApi = drive.DriveApi(authenticatedClient);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in to Google: $e');
      }
      return false;
    }
  }

  // Sign out from Google account
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _currentUser != null && _driveApi != null;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }

  // Upload file to Google Drive
  Future<String?> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    String? folderId,
    bool replaceExisting = false,
  }) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // If replaceExisting is true, check if file already exists and delete it
      if (replaceExisting && folderId != null) {
        final query =
            "name='$fileName' and '$folderId' in parents and trashed=false";
        final fileList = await _driveApi!.files.list(
          q: query,
          spaces: 'drive',
          $fields: 'files(id, name)',
        );

        if (fileList.files != null && fileList.files!.isNotEmpty) {
          // Delete the existing file
          for (var existingFile in fileList.files!) {
            await deleteFile(existingFile.id!);
            if (kDebugMode) {
              debugPrint('Deleted existing file: ${existingFile.name}');
            }
          }
        }
      }

      // Create file metadata
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = mimeType;

      // Add parent folder if specified
      if (folderId != null) {
        driveFile.parents = [folderId];
      }

      // Create media stream
      final media = drive.Media(
        Stream.value(fileBytes.toList()),
        fileBytes.length,
      );

      // Upload file
      final response = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      if (kDebugMode) {
        debugPrint('File uploaded to Google Drive: ${response.id}');
      }

      return response.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading file to Google Drive: $e');
      }
      rethrow;
    }
  }

  // Find or create folder
  Future<String?> findOrCreateFolder(String folderName) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // Search for existing folder
      final query =
          "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }

      // Create new folder if not found
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final response = await _driveApi!.files.create(folder);
      return response.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finding/creating folder: $e');
      }
      rethrow;
    }
  }

  // List files in a folder
  Future<List<drive.File>> listFiles({String? folderId}) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      String query = 'trashed=false';
      if (folderId != null) {
        query += " and '$folderId' in parents";
      }

      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name, mimeType, createdTime, size)',
        orderBy: 'createdTime desc',
      );

      return fileList.files ?? [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing files: $e');
      }
      rethrow;
    }
  }

  // Download file from Google Drive
  Future<Uint8List?> downloadFile(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await for (var data in media.stream) {
        dataStore.addAll(data);
      }

      return Uint8List.fromList(dataStore);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error downloading file: $e');
      }
      rethrow;
    }
  }

  // Delete file from Google Drive
  Future<void> deleteFile(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      await _driveApi!.files.delete(fileId);
      if (kDebugMode) {
        debugPrint('File deleted from Google Drive: $fileId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting file: $e');
      }
      rethrow;
    }
  }
}
