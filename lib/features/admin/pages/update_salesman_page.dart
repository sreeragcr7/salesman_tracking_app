import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
      appBar: AppBar(title: const Text('Update Salesman')),
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

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter salesman name.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Please enter email.';
                        }

                        if (!email.contains('@')) {
                          return 'Please enter a valid email.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        helperText: 'Only change the password if needed.',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: isBusy ? null : _togglePasswordVisibility,
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        final password = value?.trim() ?? '';

                        if (password.isNotEmpty && password.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!isBusy) {
                          _updateSalesman();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isBusy ? null : _updateSalesman,
                        icon: isBusy
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isUploadingImage
                              ? 'Uploading Image...'
                              : isLoading
                              ? 'Updating...'
                              : 'Update Salesman',
                        ),
                      ),
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
