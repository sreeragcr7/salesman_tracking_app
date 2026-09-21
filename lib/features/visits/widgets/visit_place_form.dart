import 'package:flutter/material.dart';

class VisitPlaceForm extends StatelessWidget {
  final TextEditingController shopNameController;
  final TextEditingController descriptionController;

  const VisitPlaceForm({super.key, required this.shopNameController, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: shopNameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Shop / Place Name',
            hintText: 'Enter the name of the place',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.store_outlined),
          ),
          validator: _validateShopName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe the work completed at this place',
            border: OutlineInputBorder(),
            prefixIcon: Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.description_outlined)),
          ),
        ),
      ],
    );
  }

  String? _validateShopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the place name.';
    }

    return null;
  }
}
