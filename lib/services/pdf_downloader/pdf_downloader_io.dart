import 'dart:io';
import 'dart:typed_data';

Future<String?> saveAndLaunchPdf(Uint8List bytes, String filename) async {
  try {
    String? downloadsPath;
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        downloadsPath = '$userProfile\\Downloads';
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        downloadsPath = '$home/Downloads';
      }
    }

    Directory dir;
    if (downloadsPath != null && Directory(downloadsPath).existsSync()) {
      dir = Directory(downloadsPath);
    } else {
      dir = Directory.current;
    }

    final sanitizedName =
        filename.toLowerCase().endsWith('.pdf') ? filename : '$filename.pdf';
    final file = File('${dir.path}${Platform.pathSeparator}$sanitizedName');
    await file.writeAsBytes(bytes, flush: true);

    // Automatically open the downloaded PDF in the system default viewer
    try {
      if (Platform.isWindows) {
        Process.run('cmd', ['/c', 'start', '', file.path]);
      } else if (Platform.isMacOS) {
        Process.run('open', [file.path]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [file.path]);
      }
    } catch (_) {}

    return file.path;
  } catch (e) {
    return null;
  }
}
