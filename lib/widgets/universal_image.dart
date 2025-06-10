import 'dart:convert';
import 'package:flutter/material.dart';

/// A universal image widget that handles both network URLs and base64 images.
/// Shows a fallback icon if the image fails to load.
class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  bool get _isBase64Image => imageUrl.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (_isBase64Image) {
      try {
        final base64Str = imageUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      } catch (e) {
        imageWidget = _fallbackIcon();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
      );
    }
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!, // Cast to non-nullable, since we checked
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _fallbackIcon() => Container(
    width: width,
    height: height,
    color: Colors.grey[200],
    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
  );
}
