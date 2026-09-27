// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> saveAndLaunchPdf(Uint8List bytes, String filename) async {
  try {
    final sanitizedName =
        filename.toLowerCase().endsWith('.pdf') ? filename : '$filename.pdf';
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', sanitizedName)
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'Downloaded to your Downloads folder';
  } catch (e) {
    return null;
  }
}
