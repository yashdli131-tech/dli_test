import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/kyc_data.dart';
import '../../core/kyc_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kyc_text_field.dart';
import '../../core/route_names.dart';

/// Screen 2 - Aadhaar Details (Aadhaar number only)
class AadhaarDetailsScreen extends StatefulWidget {
  const AadhaarDetailsScreen({super.key});

  @override
  State<AadhaarDetailsScreen> createState() => _AadhaarDetailsScreenState();
}

class _AadhaarDetailsScreenState extends State<AadhaarDetailsScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final digits = _ctrl.text.replaceAll(' ', '');
    if (digits.length != 12) {
      setState(() => _error = 'Please enter a valid 12-digit Aadhaar number');
      return;
    }
    setState(() => _error = null);
    KycData.aadhaar = digits;
    try {
      KycData.aadhaarClientId = await KycService.generateAadhaarOtp(digits);
      KycData.aadhaarError = null;
      if (mounted) Navigator.pushNamed(context, R.aadhaarOtp);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return KycScaffold(
      title: 'Aadhaar Verification',
      backRoute: R.home,
      rightTitle: 'Verify with your\nAadhaar',
      rightText:
          'Enter your 12-digit Aadhaar number. We will send an OTP to the mobile number linked with it.',
      steps: const [KycStepState.active, KycStepState.idle, KycStepState.idle],
      bottom: PrimaryButton(text: 'Continue', onTap: _continue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KycStepper(
            states: [KycStepState.active, KycStepState.idle, KycStepState.idle],
            lines: [false, false],
          ),
          const SizedBox(height: 20),
          const _AadhaarCardIllustration(),
          const SizedBox(height: 22),
          Text('Enter Aadhaar Details', style: ts(16, w: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Please provide your 12-digit Aadhaar number\n(as per Aadhaar card).',
              style: ts(13, color: C.muted, height: 1.5)),
          const SizedBox(height: 22),
          Text('Aadhaar Number', style: ts(14, w: FontWeight.w600)),
          const SizedBox(height: 10),
          KycTextField(
            controller: _ctrl,
            hint: 'XXXX XXXX 1234',
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              AadhaarFormatter(),
            ],
            error: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
    );
  }
}

class _AadhaarCardIllustration extends StatelessWidget {
  const _AadhaarCardIllustration();

  Widget _bar(double widthFactor, Color c, {Gradient? g, double h = 10}) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: h,
          decoration: BoxDecoration(
              color: g == null ? c : null,
              gradient: g,
              borderRadius: BorderRadius.circular(6)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Avatar(size: 86),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _bar(
                  1,
                  Colors.orange,
                  g: const LinearGradient(
                      colors: [Color(0xFFF5A02C), Color(0xFFF5A02C), Color(0xFF3FA25A)]),
                ),
                const SizedBox(height: 7),
                _bar(1, const Color(0xFFBFE3C9)),
                const SizedBox(height: 14),
                _bar(0.8, C.lightGrey),
                const SizedBox(height: 9),
                _bar(1, C.lightGrey),
                const SizedBox(height: 9),
                _bar(0.62, C.lightGrey),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const QrMark(size: 74),
        ],
      ),
    );
  }
}

