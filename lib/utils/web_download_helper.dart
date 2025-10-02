// Web-specific utilities for file download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

class WebDownloadHelper {
  static void downloadFile(String content, String fileName) {
    // Konwertuj string JSON na UTF-8 bytes używając Uint8List
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrl(blob);
    
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    
    html.Url.revokeObjectUrl(url);
  }
}