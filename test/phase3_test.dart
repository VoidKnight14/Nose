import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/models/library_resource.dart';
import 'package:name_none/services/library_storage_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Archivos de la Biblioteca', () {
    test('un recurso anterior a la Fase 3 no tiene archivo local', () {
      final resource = LibraryResource.fromJson({
        'id': 'old',
        'title': 'Apunte viejo',
        'category': 'Matemática',
        'fileType': 'PDF',
        'fileSize': '2.4 MB',
        'description': '',
        'dateAdded': DateTime.now().toIso8601String(),
      });

      expect(resource.localPath, isEmpty);
      expect(resource.hasFile, isFalse);
    });

    test('toJson y fromJson conservan la ruta local y el tamaño', () {
      final resource = LibraryResource(
        id: 'r-1',
        title: 'Parcial resuelto',
        category: 'Matemática',
        fileType: 'PDF',
        fileSize: '2.4 MB',
        description: 'Resolución paso a paso',
        dateAdded: DateTime(2026, 11, 5),
        localPath: 'library/r-1.pdf',
      );

      final restored = LibraryResource.fromJson(resource.toJson());
      expect(restored.localPath, equals('library/r-1.pdf'));
      expect(restored.hasFile, isTrue);
      expect(restored.fileSize, equals('2.4 MB'));
    });

    test('el tamaño se calcula desde bytes reales', () {
      expect(formatFileSize(0), equals('0 B'));
      expect(formatFileSize(1023), equals('1023 B'));
      expect(formatFileSize(1024), equals('1 KB'));
      expect(formatFileSize(1536), equals('1.5 KB'));
      expect(formatFileSize(2516582), equals('2.4 MB'));
    });

    test('la extensión se obtiene del nombre sin el punto', () {
      expect(
        const PickedLibraryFile(name: 'apunte.PDF', path: 'x', size: 1)
            .extension,
        equals('pdf'),
      );
      expect(
        const PickedLibraryFile(name: 'sin-extension', path: 'x', size: 1)
            .extension,
        isEmpty,
      );
    });
  });
}
