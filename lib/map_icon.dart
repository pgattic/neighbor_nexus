import 'package:flutter/material.dart';

class MapIcon {
  static IconData getGraphic(String input) {
    switch (input) {
      case 'One':
        return Icons.one_k_outlined;
      case 'Two':
        return Icons.two_k;
      case 'Three':
        return Icons.three_k;
      default:
        return Icons.question_mark;
    }
  }
}

