import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/kyc_data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../../core/route_names.dart';
import 'terms_and_conditions_screen.dart';
import '../../core/open_terms_stub.dart' if (dart.library.html) '../../core/open_terms_web.dart' as terms;

/// Screen 5 - Aadhaar Verified
class AadhaarVerifiedScreen extends StatefulWidget {
  const AadhaarVerifiedScreen({super.key});

  @override
  State<AadhaarVerifiedScreen> createState() => _AadhaarVerifiedScreenState();
}

class _AadhaarVerifiedScreenState extends State<AadhaarVerifiedScreen> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return KycScaffold(
      title: 'Aadhaar Verification',
      bottom: PrimaryButton(
        text: 'Next',
        onTap: _termsAccepted ? () => Navigator.pushNamed(context, R.panDetails) : null,
      ),
      body: Column(
        children: [
          const KycStepper(
            states: [KycStepState.done, KycStepState.idle, KycStepState.idle],
            lines: [true, false],
          ),
          const SizedBox(height: 18),
          const SuccessBadge(),
          const SizedBox(height: 22),
          Text('Aadhaar Verified', style: ts(26, w: FontWeight.w800)),
          const SizedBox(height: 10),
          Text('Your Aadhaar has been successfully\nverified.',
              textAlign: TextAlign.center,
              style: ts(14, color: C.muted, height: 1.5)),
          const SizedBox(height: 26),
          WhiteCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const IconBox(child: AadhaarIcon(size: 40)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aadhaar Number', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarMasked,
                          style: ts(14, w: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Name', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarName,
                          style: ts(14, w: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Date of birth', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarDateOfBirth.isEmpty ? '19 Sep 2004' : KycData.aadhaarDateOfBirth,
                          style: ts(14, w: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Gender', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarGender.isEmpty ? 'Not provided' : KycData.aadhaarGender,
                          style: ts(14, w: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Address', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarAddress.isEmpty ? '123 Dholka Road, Saroda-Dholka, Ahmedabad, Gujarat, 382225' : KycData.aadhaarAddress,
                          style: ts(14, w: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Mobile number', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarMobile, style: ts(14, w: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _termsAccepted,
                activeColor: C.blue,
                onChanged: (value) =>
                    setState(() => _termsAccepted = value ?? false),
              ),
              Expanded(
                child: Wrap(
                  children: [
                    const Text('I agree to the '),
                    InkWell(
                      onTap: () async {
                        if (kIsWeb) {
                          terms.openTermsPdf();
                          return;
                        }
                        final accepted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsAndConditionsScreen(),
                          ),
                        );
                        if (accepted == true && mounted) {
                          setState(() => _termsAccepted = true);
                        }
                      },
                      child: Text(
                        'Terms and Conditions',
                        style: ts(13, color: C.blue).copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
