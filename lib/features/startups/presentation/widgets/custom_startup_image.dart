import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomStartupImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const CustomStartupImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? const Icon(Icons.broken_image_rounded),
      );
    } else {
      if (kIsWeb) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              placeholder ?? const Icon(Icons.broken_image_rounded),
        );
      }
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? const Icon(Icons.broken_image_rounded),
      );
    }
  }
}
