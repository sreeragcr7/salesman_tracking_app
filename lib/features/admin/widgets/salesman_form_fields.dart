import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/validators/validators.dart';
import 'package:salesman_tracking_app/core/widgets/app_text_field.dart';

class SalesmanFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  final VoidCallback onSubmitted;

  const SalesmanFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: nameController,
          labelText: 'Name',
          hintText: 'Enter salesman name',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: Validators.name,
        ),

        const SizedBox(height: 16),

        AppTextField(
          controller: emailController,
          labelText: 'Email',
          hintText: 'salesman@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.email,
        ),

        const SizedBox(height: 16),

        AppTextField(
          controller: passwordController,
          labelText: 'Password',
          hintText: 'Enter password',
          prefixIcon: Icons.lock_outline,
          textInputAction: TextInputAction.done,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
          validator: Validators.password,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }
}
