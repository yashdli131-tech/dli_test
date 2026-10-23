import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/kyc_data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../../core/route_names.dart';
import 'terms_and_conditions_screen.dart';
import '../../core/open_terms_stub.dart' if (dart.library.html) '../../core/open_terms_web.dart' as terms;

/// Screen 9 - PAN Verified / Review & Confirm
class PanVerifiedScreen extends StatefulWidget {
  const PanVerifiedScreen({super.key});

  @override
  State<PanVerifiedScreen> createState() => _PanVerifiedScreenState();
}

class _PanVerifiedScreenState extends State<PanVerifiedScreen> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return KycScaffold(
      title: 'Review & Confirm',
      bottom: PrimaryButton(
        text: 'Next',
        onTap: _termsAccepted ? () => Navigator.pushNamed(context, R.completed) : null,
      ),
      body: Column(
        children: [
          const KycStepper(
            states: [KycStepState.done, KycStepState.done, KycStepState.active],
            lines: [true, true],
          ),
          const SizedBox(height: 18),
          const SuccessBadge(),
          const SizedBox(height: 22),
          Text('PAN Verified', style: ts(26, w: FontWeight.w800)),
          const SizedBox(height: 10),
          Text('Your PAN has been successfully\nverified.',
              textAlign: TextAlign.center,
              style: ts(14, color: C.muted, height: 1.5)),
          const SizedBox(height: 24),
          const KycSummaryCard(),
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

/// Card listing the verified Aadhaar and PAN details.
class KycSummaryCard extends StatelessWidget {
  final bool showAadhaar;
  final bool showPanDate;
  const KycSummaryCard({
    super.key,
    this.showAadhaar = false,
    this.showPanDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (showAadhaar && !KycData.isOrganization) ...[
            Row(
              children: [
                const IconBox(size: 58, child: AadhaarIcon(size: 34)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aadhaar Number', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaar.isEmpty ? KycData.aadhaarMasked : KycData.aadhaar,
                          style: ts(15, w: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Name', style: ts(12, color: C.muted)),
                      Text(KycData.aadhaarName,
                          style: ts(14, w: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: C.border),
            ),
          ],
          Row(
            children: [
              const IconBox(size: 58, child: PanIcon(size: 34)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PAN Number', style: ts(12, color: C.muted)),
                    Text(KycData.pan.isEmpty ? KycData.panValue : KycData.pan, style: ts(15, w: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Name', style: ts(12, color: C.muted)),
                    Text(KycData.panName, style: ts(14, w: FontWeight.w600)),
                    if (showPanDate) ...[
                      const SizedBox(height: 6),
                      Text('Date of birth', style: ts(12, color: C.muted)),
                      Text(KycData.panDateOfBirth.isEmpty ? 'Not provided' : KycData.panDateOfBirth,
                          style: ts(14, w: FontWeight.w600)),
                    ],
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
