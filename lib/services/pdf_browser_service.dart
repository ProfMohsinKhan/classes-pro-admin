import 'pdf_browser_service_stub.dart'
    if (dart.library.html) 'pdf_browser_service_web.dart';

Future<bool> openPdfInBrowser({
  required List<int> bytes,
  required String fileName,
}) {
  return openPdfBytes(bytes: bytes, fileName: fileName);
}
