import 'package:flutter/material.dart';

class CustomImageLoader extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const CustomImageLoader({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xffF2762E),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey[400],
                  size: 24,
                ),
                if (height != null && height! > 50)
                  const Text(
                    "Error",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(Icons.error_outline, color: Colors.grey[400]),
          );
        },
      );
    }
  }
}
