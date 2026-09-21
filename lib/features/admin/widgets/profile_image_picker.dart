import 'dart:io';

import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback? onTap;

  const ProfileImagePicker({super.key, required this.selectedImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null ? const Icon(Icons.person, size: 55) : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to select profile image',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
