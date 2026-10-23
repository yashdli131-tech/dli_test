import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../../core/kyc_data.dart';
import '../../core/route_names.dart';

/// Screen 1 - KYC Verification
///
///  Normal User  -> Aadhaar + PAN. PAN stays locked until Aadhaar is verified.
///  Organization -> PAN only.
class KycHomeScreen extends StatelessWidget {
  const KycHomeScreen({super.key});

  void _openPan(BuildContext context) {
    if (!KycData.canVerifyPan) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(KycData.aadhaarFirstMessage),
          behavior: SnackBarBehavior.floating,
          width: 420,
          backgroundColor: C.navy,
        ));
      return;
    }
    Navigator.pushNamed(context, R.pan);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds by itself when the user type or the Aadhaar status changes.
    return ListenableBuilder(
      listenable: KycData.changes,
      builder: (context, _) {
        final org = KycData.isOrganization;
        final panLocked = !KycData.canVerifyPan;
        final steps = org
            ? const [KycStepState.done, KycStepState.active, KycStepState.idle]
            : const [KycStepState.active, KycStepState.idle, KycStepState.idle];
        return KycScaffold(
          title: 'KYC Verification',
          titleSize: 30,
          subtitle: 'Complete your KYC to access all our services',
          rightTitle: org
              ? 'Verify your organization\nwith PAN'
              : 'Complete your KYC\nin 3 easy steps',
          rightText: org
              ? 'Organizations only need PAN verification. Verify once and unlock every DLI service.'
              : 'Verify with Aadhaar and PAN once, and unlock every DLI service in minutes.',
          steps: steps,
          bottom: WhiteCard(
            color: C.lightGrey.withOpacity(0.8),
            borderColor: C.border.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: C.blue, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your data is safe with us',
                          style: ts(14, w: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                          'We use bank-grade security to protect your information.',
                          style: ts(12.5, color: C.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              UserTypeTabs(
                value: KycData.userType,
                onChanged: (t) => KycData.userType = t,
              ),
              const SizedBox(height: 22),
              KycStepper(
                states: steps,
                lines: org ? const [true, false] : const [false, false],
              ),
              const SizedBox(height: 22),
              if (!org) ...[
                _OptionCard(
                  highlighted: !KycData.aadhaarVerified,
                  verified: KycData.aadhaarVerified,
                  icon: const AadhaarIcon(size: 40),
                  title: 'Aadhaar Verification',
                  subtitle: 'Verify your identity using Aadhaar card',
                  onTap: () => Navigator.pushNamed(context, R.aadhaar),
                ),
                const SizedBox(height: 14),
              ],
              _OptionCard(
                highlighted: !panLocked,
                locked: panLocked,
                hint: panLocked ? KycData.aadhaarFirstMessage : null,
                icon: const PanIcon(size: 40),
                title: 'PAN Verification',
                subtitle: 'Verify your identity using PAN card',
                onTap: () => _openPan(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final bool highlighted;
  final bool locked; // disabled (PAN before Aadhaar)
  final bool verified; // green tick (Aadhaar done)
  final String? hint; // red helper text under the subtitle
  final Widget icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _OptionCard({
    this.highlighted = false,
    this.locked = false,
    this.verified = false,
    this.hint,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap, // a locked card still reacts: it shows the message
        child: WhiteCard(
          color: locked ? C.lightGrey.withOpacity(0.7) : null,
          borderColor: highlighted ? C.blue : C.border.withOpacity(0.8),
          borderWidth: highlighted ? 1.5 : 1,
          child: Row(
            children: [
              Opacity(
                  opacity: locked ? 0.45 : 1,
                  child: IconBox(size: 62, child: icon)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: ts(16,
                            w: FontWeight.w700,
                            color: locked ? C.muted : C.navy)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: ts(13, color: C.muted)),
                    if (hint != null) ...[
                      const SizedBox(height: 6),
                      Text(hint!,
                          style: ts(12.5, w: FontWeight.w600, color: C.error)),
                    ],
                  ],
                ),
              ),
              if (locked)
                const Icon(Icons.lock_outline_rounded, color: C.muted, size: 24)
              else if (verified)
                const Icon(Icons.check_circle_rounded, color: C.green, size: 26)
              else
                const Icon(Icons.chevron_right, color: C.navy, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
