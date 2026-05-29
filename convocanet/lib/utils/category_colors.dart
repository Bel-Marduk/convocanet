import 'package:flutter/material.dart';

Color getCategoryColor(String? slug) {
  switch (slug) {
    case 'educacion':
      return const Color(0xFF6366f1);
    case 'salud':
      return const Color(0xFFEc4899);
    case 'tecnologia':
      return const Color(0xFF8b5cf6);
    case 'cultura':
      return const Color(0xFFF59e0b);
    case 'social':
      return const Color(0xFF06b6d4);
    default:
      return const Color(0xFF4f46e5);
  }
}
