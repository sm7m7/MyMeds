import 'package:flutter/material.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MedicalDisclaimer(),
            SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text('Search for medications here.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
