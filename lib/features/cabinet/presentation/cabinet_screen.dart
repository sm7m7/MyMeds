import 'package:flutter/material.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';

class CabinetScreen extends StatelessWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cabinet')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MedicalDisclaimer(),
            SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text('Your medication cabinet will appear here.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
