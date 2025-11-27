import 'dart:io';

import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

class PhotoEditorScreen extends StatelessWidget {
  final String imagePath;

  const PhotoEditorScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Photo'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(File(imagePath))
            : const Text('No image selected'),
      ),
    );
  }
}





