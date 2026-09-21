import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/location_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../bloc/visit_bloc.dart';

class AddVisitPage extends StatelessWidget {
  final String tripId;

  const AddVisitPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitBloc(userRepository: UserRepository(), locationService: LocationService()),
      child: _AddVisitView(tripId: tripId),
    );
  }
}

class _AddVisitView extends StatefulWidget {
  final String tripId;

  const _AddVisitView({required this.tripId});

  @override
  State<_AddVisitView> createState() => _AddVisitViewState();
}

class _AddVisitViewState extends State<_AddVisitView> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final List<File> _selectedMedia = [];

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);

    if (file == null) return;

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _pickPhoto() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (file == null) return;

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _recordVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.camera);

    if (file == null) return;

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (file == null) return;

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  void _submitVisit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<VisitBloc>().add(
      VisitSubmissionRequested(
        tripId: widget.tripId,
        shopName: _shopNameController.text,
        description: _descriptionController.text,
        mediaFiles: _selectedMedia,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: (context, state) {
        if (state is VisitSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit submitted successfully.')));

          Navigator.of(context).pop();
        }

        if (state is VisitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Visit')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Place Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _shopNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Shop / Place Name',
                      hintText: 'Enter the name of the place',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the place name.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the work completed at this place',
                      border: OutlineInputBorder(),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Visit Media', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _buildMediaPreview(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take Photo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Photo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _recordVideo,
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Record Video'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.video_library_outlined),
                          label: const Text('Video'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your current location will be captured automatically when you submit this visit.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<VisitBloc, VisitState>(
                    builder: (context, state) {
                      final isSubmitting = state is VisitSubmitting;

                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: isSubmitting ? null : _submitVisit,
                          icon: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline),
                          label: Text(isSubmitting ? 'Submitting...' : 'Submit Visit'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia.isEmpty) {
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_selectedMedia.length, (index) {
        final file = _selectedMedia[index];

        final extension = file.path.split('.').last.toLowerCase();

        final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.grey.shade200,
                child: isVideo
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
                onTap: () {
                  setState(() {
                    _selectedMedia.removeAt(index);
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
