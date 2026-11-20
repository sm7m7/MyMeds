import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Shows a medication photo (stored as base64). Falls back to an icon.
class MedicationPhotoView extends StatelessWidget {
  const MedicationPhotoView({
    super.key,
    required this.photoBase64,
    this.size = 96,
  });

  final String? photoBase64;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = photoBase64 != null && photoBase64!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        color: scheme.primaryContainer,
        child: hasPhoto
            ? Image.memory(
          base64Decode(photoBase64!),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        )
            : Icon(Icons.medication, size: size / 2, color: scheme.primary),
      ),
    );
  }
}

/// Photo preview with a button to take, choose, or remove the picture.
class MedicationPhotoPicker extends StatelessWidget {
  const MedicationPhotoPicker({
    super.key,
    required this.photoBase64,
    required this.onChanged,
  });

  final String? photoBase64;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onChanged(base64Encode(bytes));
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            if (photoBase64 != null && photoBase64!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  onChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          MedicationPhotoView(photoBase64: photoBase64, size: 120),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openSheet(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              photoBase64 == null || photoBase64!.isEmpty
                  ? 'Add photo'
                  : 'Change photo',
            ),
          ),
        ],
      ),
    );
  }
}