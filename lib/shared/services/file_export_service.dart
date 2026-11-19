import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileExportService {
  const FileExportService();

  // Guarda el PDF en la carpeta temporal y abre el menú de compartir del
  // sistema (ver, guardar en Drive/Archivos, enviar...). No se conserva
  // porque se puede volver a generar desde la venta.
  Future<File> saveAndSharePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: fileName,
      ),
    );

    return file;
  }
}