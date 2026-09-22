import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesman_tracking_app/core/widgets/app_app_bar.dart';
import 'package:salesman_tracking_app/core/widgets/primary_button.dart';

import '../bloc/admin_bloc.dart';
import '../widgets/create_salesman_header.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/salesman_form_fields.dart';

class CreateSalesmanPage extends StatefulWidget {
  const CreateSalesmanPage({super.key});

  @override
  State<CreateSalesmanPage> createState() => _CreateSalesmanPageState();
}

class _CreateSalesmanPageState extends State<CreateSalesmanPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _obscurePassword = true;

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

  void _createSalesman() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AdminBloc>().add(
      AdminSalesmanCreateRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        profileImage: _selectedImage?.path,
      ),
    );
  }

  void _handleStateChange(BuildContext context, AdminState state) {
    if (state is AdminSalesmanLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salesman created successfully.')));

      Navigator.of(context).pop();
    }

    if (state is AdminSalesmenFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Create Salesman'),
      body: BlocListener<AdminBloc, AdminState>(
        listener: _handleStateChange,
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            final isLoading = state is AdminSalesmanLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CreateSalesmanHeader(),

                    const SizedBox(height: 32),

                    ProfileImagePicker(selectedImage: _selectedImage, onTap: isLoading ? null : _pickProfileImage),

                    const SizedBox(height: 24),

                    SalesmanFormFields(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: _togglePasswordVisibility,
                      onSubmitted: () {
                        if (!isLoading) {
                          _createSalesman();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                      label: 'Create Salesman',
                      loadingLabel: 'Creating...',
                      onPressed: _createSalesman,
                      isLoading: isLoading,
                      icon: Icons.person_add,
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
