/// Archivo elegido por el usuario, antes de copiarlo al almacenamiento privado.
class PickedLibraryFile {
  final String name;
  final String path;
  final int size;

  const PickedLibraryFile({
    required this.name,
    required this.path,
    required this.size,
  });

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return '';
    final ext = name.substring(dot + 1).toLowerCase();
    // El nombre viene de un proveedor externo: solo se aceptan extensiones simples.
    return RegExp(r'^[a-z0-9]{1,10}$').hasMatch(ext) ? ext : '';
  }
}

/// Tamaño legible calculado desde bytes reales.
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${_oneDecimal(kb)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${_oneDecimal(mb)} MB';
  return '${_oneDecimal(mb / 1024)} GB';
}

String _oneDecimal(double value) {
  return value.toStringAsFixed(1).replaceAll('.0', '');
}
