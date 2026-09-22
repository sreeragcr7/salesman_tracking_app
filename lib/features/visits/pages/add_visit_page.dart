import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesman_tracking_app/domain/usecases/media/create_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/visits/create_visit.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

import '../../../core/services/location_service.dart';
import '../bloc/visit_bloc.dart';
import '../widgets/visit_location_notice.dart';
import '../widgets/visit_media_section.dart';
import '../widgets/visit_place_form.dart';

class AddVisitPage extends StatelessWidget {
  final String tripId;

  const AddVisitPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitBloc(
        createVisit: sl<CreateVisit>(),
        uploadVisitMedia: sl<UploadVisitMedia>(),
        createVisitMedia: sl<CreateVisitMedia>(),
        locationService: LocationService(),
      ),
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

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _pickPhoto() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _recordVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.camera);

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMedia.add(File(file.path));
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
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

  void _handleVisitState(BuildContext context, VisitState state) {
    if (state is VisitSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit submitted successfully.')));

      Navigator.of(context).pop();
    }

    if (state is VisitFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: _handleVisitState,
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
                  VisitPlaceForm(
                    shopNameController: _shopNameController,
                    descriptionController: _descriptionController,
                  ),
                  const SizedBox(height: 28),
                  VisitMediaSection(
                    selectedMedia: _selectedMedia,
                    onTakePhoto: _takePhoto,
                    onPickPhoto: _pickPhoto,
                    onRecordVideo: _recordVideo,
                    onPickVideo: _pickVideo,
                    onRemoveMedia: _removeMedia,
                  ),
                  const SizedBox(height: 28),
                  const VisitLocationNotice(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<VisitBloc, VisitState>(
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
    );
  }
}
