import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../theme.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late final PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/terms-and-conditions.pdf'),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PdfViewPinch(
                controller: _pdfController,
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  pageLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (_, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not open the terms PDF: $error'),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Accept and Return'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
