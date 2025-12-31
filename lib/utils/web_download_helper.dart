// Web-specific utilities for file download
import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class WebDownloadHelper {
  static void downloadFile(String content, String fileName) {
    // Convert JSON string to UTF-8 bytes
    final bytes = utf8.encode(content);
    final uint8List = Uint8List.fromList(bytes);

    // Create blob using js_interop
    final blobParts = <JSAny>[uint8List.toJS].toJS;
    final options = web.BlobPropertyBag(type: 'application/json');
    final blob = web.Blob(blobParts, options);
    final url = web.URL.createObjectURL(blob);

    // Create and click anchor element
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    anchor.style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);

    web.URL.revokeObjectURL(url);
  }
}
