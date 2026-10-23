import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/kyc_data.dart';
import '../../core/route_names.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kyc_text_field.dart';

/// Screen 6 (showCard: true) - PAN Details with card illustration
/// Screen 7 (showCard: false) - PAN Page, only the PAN number
class PanScreen extends StatefulWidget {
  final bool showCard;
  const PanScreen({super.key, this.showCard = true});

  @override
  State<PanScreen> createState() => _PanScreenState();
}

class _PanScreenState extends State<PanScreen> {
  final _ctrl = TextEditingController();
  String? _error = KycData.panError;

  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continue() {
    final v = _ctrl.text.trim().toUpperCase();
    if (!_panRegex.hasMatch(v)) {
      setState(() => _error = 'Please enter a valid 10-character PAN (e.g. ABCDE1234F)');
      return;
    }
    KycData.pan = v;
    KycData.panError = null;
    Navigator.pushNamed(context, R.panVerifying);
  }

  @override
  Widget build(BuildContext context) {
    return KycScaffold(
      title: 'PAN Verification',
      backRoute: widget.showCard ? R.aadhaarVerified : R.home,
      bottom: PrimaryButton(text: 'Continue', onTap: _continue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KycStepper(
            states: [KycStepState.done, KycStepState.active, KycStepState.idle],
            lines: [true, false],
          ),
          const SizedBox(height: 20),
          if (widget.showCard) ...[
            const _PanCardIllustration(),
            const SizedBox(height: 22),
            Text('Enter PAN Details', style: ts(16, w: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Please provide your 10-digit PAN number\n(as per PAN card).',
                style: ts(13, color: C.muted, height: 1.5)),
            const SizedBox(height: 18),
          ] else
            const SizedBox(height: 4),
          Text('PAN Number', style: ts(14, w: FontWeight.w600)),
          const SizedBox(height: 10),
          KycTextField(
            controller: _ctrl,
            hint: 'ABCDE1234F',
            capitalization: TextCapitalization.characters,
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              UpperCaseFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            error: _error,
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
                KycData.panError = null;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PanCardIllustration extends StatelessWidget {
  const _PanCardIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC9C7F2), Color(0xFFC3DCF7), Color(0xFFBBDDF9)],
        ),
        boxShadow: [
          BoxShadow(
              color: C.blue.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INCOME TAX DEPARTMENT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, w: FontWeight.w700),
                    ),
                    Text(
                      'GOVERNMENT OF INDIA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(7.5, w: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PAN CARD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, w: FontWeight.w700),
                    ),
                    Text(
                      'TAX IDENTIFICATION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(7.5, w: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Avatar(size: 82, bg: Color(0xFFDDE0F7)),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                      height: 2, color: C.navy.withOpacity(0.15)),
                ),
              ),
              const SizedBox(width: 16),
              const QrMark(size: 66),
            ],
          ),
        ],
      ),
    );
  }
}


