// Example usage of ReceiptImagePicker widget
// This file demonstrates how to integrate the ReceiptImagePicker in a form

import 'package:flutter/material.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/receipt_image_picker.dart';

class ReceiptImagePickerExample extends StatefulWidget {
  const ReceiptImagePickerExample({super.key});

  @override
  State<ReceiptImagePickerExample> createState() => _ReceiptImagePickerExampleState();
}

class _ReceiptImagePickerExampleState extends State<ReceiptImagePickerExample> {
  String? _receiptImageBase64;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Image Picker Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Image Picker Widget
            ReceiptImagePicker(
              onImageSelected: (base64Image) {
                setState(() {
                  _receiptImageBase64 = base64Image;
                });
                // You can now use the base64Image for API submission
                debugPrint('Image selected, base64 length: ${base64Image.length}');
              },
              onImageRemoved: () {
                setState(() {
                  _receiptImageBase64 = null;
                });
                debugPrint('Image removed');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Display status
            if (_receiptImageBase64 != null)
              Text(
                'Receipt image ready (${_receiptImageBase64!.length} characters)',
                style: const TextStyle(color: Colors.green),
              )
            else
              const Text(
                'No receipt image selected',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
