import 'package:diacritic/diacritic.dart' as diacritics;
import 'package:flutter/services.dart';

extension StringNullableExtension on String? {
  String capitalizeFirstLetter() {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return this![0].toUpperCase() + this!.substring(1);
  }

  String? normalize() {
    if (this == null) {
      return null;
    }
    return diacritics.removeDiacritics(this!);
  }

  String capitalizeAllFirstLetter() {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return this!.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension StringExtension on String {
  String toPhotoUrl() {
    return (appFlavor == 'development')
        ? 'https://ik.imagekit.io/caminoninjadev/$this'
        : 'https://ik.imagekit.io/camino/$this';
  }
}
