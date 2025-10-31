import 'package:flutter/material.dart';

/// Goal color palette and utilities
///
/// This class provides predefined color gradients for goals and utility methods
/// to retrieve colors based on index.
class GoalColors {
  GoalColors._();

  /// Predefined color gradients for goals
  static const List<List<Color>> gradients = [
    // Pink to Purple
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    // Purple to Blue
    [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    // Orange to Red
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    // Green to Dark Green
    [Color(0xFF10B981), Color(0xFF059669)],
    // Cyan to Blue
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    // Indigo to Purple
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    // Teal to Emerald
    [Color(0xFF14B8A6), Color(0xFF10B981)],
    // Rose to Pink
    [Color(0xFFF43F5E), Color(0xFFEC4899)],
    // Amber to Orange
    [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    // Violet to Purple
    [Color(0xFF7C3AED), Color(0xFF6B46C1)],
  ];

  /// Color names for display in picker
  static const List<String> colorNames = [
    'Rosa',
    'Roxo',
    'Laranja',
    'Verde',
    'Azul Claro',
    'Índigo',
    'Verde Água',
    'Vermelho',
    'Amarelo',
    'Violeta',
  ];

  /// Get gradient by index
  /// If index is -1 or out of bounds, returns gradient based on fallbackIndex
  static LinearGradient getGradient(int colorIndex, {int fallbackIndex = 0}) {
    final index = colorIndex >= 0 && colorIndex < gradients.length
        ? colorIndex
        : fallbackIndex % gradients.length;

    final colors = gradients[index];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get gradient colors list by index
  static List<Color> getGradientColors(int colorIndex, {int fallbackIndex = 0}) {
    final index = colorIndex >= 0 && colorIndex < gradients.length
        ? colorIndex
        : fallbackIndex % gradients.length;

    return gradients[index];
  }

  /// Get primary color (first color of gradient) by index
  static Color getPrimaryColor(int colorIndex, {int fallbackIndex = 0}) {
    return getGradientColors(colorIndex, fallbackIndex: fallbackIndex)[0];
  }

  /// Get secondary color (second color of gradient) by index
  static Color getSecondaryColor(int colorIndex, {int fallbackIndex = 0}) {
    return getGradientColors(colorIndex, fallbackIndex: fallbackIndex)[1];
  }

  /// Get color name by index
  static String getColorName(int index) {
    if (index >= 0 && index < colorNames.length) {
      return colorNames[index];
    }
    return colorNames[index % colorNames.length];
  }

  /// Total number of available colors
  static int get colorCount => gradients.length;
}
