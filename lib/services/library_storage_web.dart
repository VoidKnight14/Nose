import 'library_storage_types.dart';

/// En web no hay acceso al almacenamiento privado de Android.
class LibraryStorage {
  static Future<PickedLibraryFile?> pick() async => null;

  static Future<String> save(PickedLibraryFile file, String id) async {
    throw UnsupportedError('La importación de archivos solo está disponible en Android.');
  }

  static Future<String?> absolutePath(String relativePath) async => null;

  static Future<bool> exists(String relativePath) async => false;

  static Future<void> delete(String relativePath) async {}

  static Future<String?> openExternally(String relativePath) async {
    return 'Abrir archivos solo está disponible en Android.';
  }
}
