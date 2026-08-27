import 'package:flutter/material.dart';

class LibraryResource {
  final String id;
  final String title;
  final String category; // e.g. "Matemática", "Informática", "Lengua", "Ciencias"
  final String fileType; // e.g. "PDF", "DOCX", "ZIP"
  final String fileSize; // e.g. "2.4 MB"
  final String description;
  final DateTime dateAdded;
  bool isFavorite;
  int readCount;

  LibraryResource({
    required this.id,
    required this.title,
    required this.category,
    required this.fileType,
    required this.fileSize,
    required this.description,
    required this.dateAdded,
    this.isFavorite = false,
    this.readCount = 0,
  });

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
}
