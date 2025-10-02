// Stub implementation for non-web platforms
class WebDownloadHelper {
  static void downloadFile(String content, String fileName) {
    throw UnsupportedError('File download is only supported on web');
  }
}