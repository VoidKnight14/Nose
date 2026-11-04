import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'library_storage_types.dart';

/// Importa y conserva archivos reales dentro del almacenamiento privado de la app.
class LibraryStorage {
  static const _folder = 'library';

  static Future<PickedLibraryFile?> pick() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Seleccionar archivo',
    );
    final path = file?.path;
    if (file == null || path == null) return null;

    return PickedLibraryFile(
      name: file.name,
      path: path,
      size: await file.length() ?? 0,
    );
  }

  /// Copia el archivo elegido y devuelve su ruta relativa.
  static Future<String> save(PickedLibraryFile file, String id) async {
    final directory = await _directory();
    final extension = file.extension;
    final fileName = extension.isEmpty ? id : '$id.$extension';
    await File(file.path).copy('${directory.path}/$fileName');
    return '$_folder/$fileName';
  }

  static Future<String?> absolutePath(String relativePath) async {
    if (relativePath.isEmpty) return null;
    final base = await getApplicationDocumentsDirectory();
    return '${base.path}/$relativePath';
  }

  static Future<bool> exists(String relativePath) async {
    final path = await absolutePath(relativePath);
    return path != null && await File(path).exists();
  }

  static Future<void> delete(String relativePath) async {
    final path = await absolutePath(relativePath);
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Devuelve un mensaje de error, o null si se abrió correctamente.
  static Future<String?> openExternally(String relativePath) async {
    final path = await absolutePath(relativePath);
    if (path == null || !await File(path).exists()) {
      return 'El archivo ya no está en el dispositivo.';
    }

    final result = await OpenFilex.open(path);
    switch (result.type) {
      case ResultType.done:
        return null;
      case ResultType.noAppToOpen:
        return 'No hay una aplicación instalada para abrir este formato.';
      case ResultType.fileNotFound:
        return 'El archivo no se encontró.';
      case ResultType.permissionDenied:
        return 'Android denegó el acceso al archivo.';
      case ResultType.error:
        return 'No se pudo abrir el archivo.';
    }
  }

  static Future<Directory> _directory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/$_folder');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
