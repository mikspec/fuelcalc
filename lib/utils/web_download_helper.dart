// Web-specific utilities for file download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebDownloadHelper {
  static void downloadFile(String content, String fileName) {
    final bytes = content.codeUnits;
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