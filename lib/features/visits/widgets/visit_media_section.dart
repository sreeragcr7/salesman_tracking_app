import 'dart:io';

import 'package:flutter/material.dart';

import 'visit_media_picker_button.dart';

class VisitMediaSection extends StatelessWidget {
  final List<File> selectedMedia;

  final VoidCallback onTakePhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback onRecordVideo;
  final VoidCallback onPickVideo;

  final ValueChanged<int> onRemoveMedia;

  const VisitMediaSection({
    super.key,
    required this.selectedMedia,
    required this.onTakePhoto,
    required this.onPickPhoto,
    required this.onRecordVideo,
    required this.onPickVideo,
    required this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visit Media', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _MediaPreview(media: selectedMedia, onRemoveMedia: onRemoveMedia),
        const SizedBox(height: 16),
        Row(
          children: [
            VisitMediaPickerButton(icon: Icons.camera_alt_outlined, label: 'Take Photo', onPressed: onTakePhoto),
            const SizedBox(width: 12),
            VisitMediaPickerButton(icon: Icons.photo_library_outlined, label: 'Photo', onPressed: onPickPhoto),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            VisitMediaPickerButton(icon: Icons.videocam_outlined, label: 'Record Video', onPressed: onRecordVideo),
            const SizedBox(width: 12),
            VisitMediaPickerButton(icon: Icons.video_library_outlined, label: 'Video', onPressed: onPickVideo),
          ],
        ),
      ],
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final List<File> media;
  final ValueChanged<int> onRemoveMedia;

  const _MediaPreview({required this.media, required this.onRemoveMedia});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return _EmptyMediaPreview();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(media.length, (index) {
        return _MediaItem(file: media[index], onRemove: () => onRemoveMedia(index));
      }),
    );
  }
}

class _EmptyMediaPreview extends StatelessWidget {
  const _EmptyMediaPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_media_outlined, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text('No media selected', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _MediaItem({required this.file, required this.onRemove});

  bool get _isVideo {
    final extension = file.path.split('.').last.toLowerCase();

    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade200,
            child: _isVideo
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.video_file_outlined, size: 48), SizedBox(height: 6), Text('Video')],
                  )
                : Image.file(file, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
