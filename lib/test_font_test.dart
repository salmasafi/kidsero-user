import 'package:flutter/material.dart';
import 'core/theme/app_text_styles.dart';

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cairo Font Test - Heading',
              style: AppTextStyles.heading(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Cairo Font Test - SubHeading',
              style: AppTextStyles.subHeading(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Cairo Font Test - Body',
              style: AppTextStyles.body(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Cairo Font Test - Button',
              style: AppTextStyles.button(context),
            ),
            const SizedBox(height: 32),
            const Text(
              'Default Text (should also be Cairo)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explicit Cairo Font',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'System Font (for comparison)',
              style: TextStyle(
                fontFamily: 'System',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Arabic Test: مرحباً بالعالم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Numbers Test: 1234567890',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
