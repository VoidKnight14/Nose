import 'package:flutter/material.dart';

class LibraryResource {
  final String id;
  final String title;
  final String category; // e.g. "Matemática", "Informática", "Lengua", "Ciencias"
  final String fileType; // e.g. "PDF", "DOCX", "ZIP"
  final String fileSize; // e.g. "2.4 MB"
  final String description;
  final DateTime dateAdded;
  final bool isFavorite;
  final int readCount;

  /// Ruta relativa dentro del almacenamiento privado. Vacía en recursos antiguos.
  final String localPath;

  const LibraryResource({
    required this.id,
    required this.title,
    required this.category,
    required this.fileType,
    required this.fileSize,
    required this.description,
    required this.dateAdded,
    this.isFavorite = false,
    this.readCount = 0,
    this.localPath = '',
  });

  bool get hasFile => localPath.isNotEmpty;

  LibraryResource copyWith({
    String? id,
    String? title,
    String? category,
    String? fileType,
    String? fileSize,
    String? description,
    DateTime? dateAdded,
    bool? isFavorite,
    int? readCount,
    String? localPath,
  }) {
    return LibraryResource(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      readCount: readCount ?? this.readCount,
      localPath: localPath ?? this.localPath,
    );
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'matemática':
      case 'matematica':
        return Icons.calculate_outlined;
      case 'informática':
      case 'informatica':
        return Icons.laptop_mac_outlined;
      case 'lengua':
      case 'literatura':
        return Icons.menu_book_outlined;
      case 'ciencias':
      case 'biología':
      case 'química':
        return Icons.science_outlined;
      default:
        return Icons.folder_open_outlined;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'matemática':
      case 'matematica':
        return const Color(0xFF6366F1); // Indigo
      case 'informática':
      case 'informatica':
        return const Color(0xFF0EA5E9); // Sky Blue
      case 'lengua':
      case 'literatura':
        return const Color(0xFFEC4899); // Pink
      case 'ciencias':
      case 'biología':
      case 'química':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'fileType': fileType,
      'fileSize': fileSize,
      'description': description,
      'dateAdded': dateAdded.toIso8601String(),
      'isFavorite': isFavorite,
      'readCount': readCount,
      'localPath': localPath,
    };
  }

  factory LibraryResource.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dateAdded']?.toString();
    if (rawDate == null || rawDate.isEmpty) {
      throw const FormatException('Fecha de recurso ausente');
    }
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) {
      throw const FormatException('Fecha de recurso inválida');
    }

    final id = json['id']?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Identificador de recurso ausente');
    }

    final title = json['title']?.toString();
    if (title == null || title.trim().isEmpty) {
      throw const FormatException('Título de recurso ausente');
    }

    return LibraryResource(
      id: id,
      title: title,
      category: json['category']?.toString() ?? 'Otro',
      fileType: json['fileType']?.toString() ?? 'PDF',
      fileSize: json['fileSize']?.toString() ?? '0 KB',
      description: json['description']?.toString() ?? '',
      dateAdded: parsedDate,
      isFavorite: json['isFavorite'] == true,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      localPath: json['localPath']?.toString() ?? '',
    );
  }
}
