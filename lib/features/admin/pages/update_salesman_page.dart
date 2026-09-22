import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesman_tracking_app/core/validators/validators.dart';
import 'package:salesman_tracking_app/core/widgets/app_app_bar.dart';
import 'package:salesman_tracking_app/core/widgets/app_text_field.dart';
import 'package:salesman_tracking_app/core/widgets/primary_button.dart';

import '../../../domain/usecases/media/upload_profile_image.dart';
import '../../../init_dependencies.dart';
import '../bloc/admin_bloc.dart';

import '../../../data/models/user_model.dart';

class UpdateSalesmanPage extends StatefulWidget {
  final UserModel salesman;

  const UpdateSalesmanPage({super.key, required this.salesman});

  @override
  State<UpdateSalesmanPage> createState() => _UpdateSalesmanPageState();
}

class _UpdateSalesmanPageState extends State<UpdateSalesmanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  bool _obscurePassword = true;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.salesman.name);

    _emailController = TextEditingController(text: widget.salesman.email);

    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200);

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _updateSalesman() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final adminBloc = context.read<AdminBloc>();

    String? profileImageUrl;

    if (_selectedImage != null) {
      setState(() {
        _isUploadingImage = true;
      });

      final uploadResult = await sl<UploadProfileImage>()(
        UploadProfileImageParams(userId: widget.salesman.uid, file: _selectedImage!),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingImage = false;
      });

      final uploadFailed = uploadResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));

          return true;
        },
        (url) {
          profileImageUrl = url;
          return false;
        },
      );

      if (uploadFailed) {
        return;
      }
    }

    final password = _passwordController.text.trim();

    adminBloc.add(
      AdminSalesmanUpdateRequested(
        userId: widget.salesman.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: password.isEmpty ? null : password,
        profileImage: profileImageUrl,
      ),
    );
  }

  void _handleStateChange(BuildContext context, AdminState state) {
    if (state is AdminSalesmanLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salesman updated successfully.')));

      Navigator.of(context).pop();
    }

    if (state is AdminSalesmenFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Update Salesman'),
      body: BlocListener<AdminBloc, AdminState>(
        listener: _handleStateChange,
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            final isLoading = state is AdminSalesmanLoading;

            final isBusy = isLoading || _isUploadingImage;

            final hasSelectedImage = _selectedImage != null;

            final hasExistingImage = widget.salesman.profileImage != null && widget.salesman.profileImage!.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: isBusy ? null : _pickProfileImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundImage: hasSelectedImage
                                  ? FileImage(_selectedImage!)
                                  : hasExistingImage
                                  ? NetworkImage(widget.salesman.profileImage!)
                                  : null,
                              child: !hasSelectedImage && !hasExistingImage ? const Icon(Icons.person, size: 52) : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: TextButton(
                        onPressed: isBusy ? null : _pickProfileImage,
                        child: const Text('Change Profile Image'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      controller: _nameController,
                      labelText: 'Name',
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _passwordController,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      helperText: 'Only change the password if needed.',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        onPressed: isBusy ? null : _togglePasswordVisibility,
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                      validator: (value) => Validators.password(value, required: false, minLength: 8),
                      onFieldSubmitted: (_) {
                        if (!isBusy) {
                          _updateSalesman();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                      label: 'Update Salesman',
                      loadingLabel: _isUploadingImage ? 'Uploading Image...' : 'Updating...',
                      onPressed: _updateSalesman,
                      isLoading: isBusy,
                      icon: Icons.save_outlined,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
