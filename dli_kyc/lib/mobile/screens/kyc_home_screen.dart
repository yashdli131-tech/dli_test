import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../../core/kyc_data.dart';
import '../../core/route_names.dart';

/// Screen 1 - KYC Verification
///
/// Normal User -> Aadhaar + PAN.
/// PAN stays locked until Aadhaar is verified.
/// Organization -> PAN only.
class KycHomeScreen extends StatelessWidget {
  const KycHomeScreen({super.key});

  void _openPan(BuildContext context) {
    if (!KycData.canVerifyPan) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(KycData.aadhaarFirstMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: C.navy,
          ),
        );
      return;
    }

    Navigator.pushNamed(context, R.pan);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: KycData.changes,
      builder: (context, _) {
        final org = KycData.isOrganization;
        final panLocked = !KycData.canVerifyPan;

        return KycScaffold(
          wave: true,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              final isSmallMobile = screenWidth <= 380;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isSmallMobile ? 14 : 20,
                  4,
                  isSmallMobile ? 14 : 20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),

                    // Page heading
                    Text(
                      'KYC Verification',
                      textAlign: TextAlign.center,
                      style: ts(
                        isSmallMobile ? 23 : 26,
                        w: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Complete your KYC to access all our services',
                      textAlign: TextAlign.center,
                      style: ts(
                        12,
                        color: C.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // User type selection
                    UserTypeTabs(
                      value: KycData.userType,
                      onChanged: (t) => KycData.userType = t,
                    ),
                    const SizedBox(height: 18),

                    // Verification steps
                    KycStepper(
                      states: org
                          ? const [
                              KycStepState.done,
                              KycStepState.active,
                              KycStepState.idle,
                            ]
                          : const [
                              KycStepState.active,
                              KycStepState.idle,
                              KycStepState.idle,
                            ],
                      lines: org
                          ? const [true, false]
                          : const [false, false],
                    ),
                    const SizedBox(height: 18),

                    // Aadhaar card: individual users only
                    if (!org) ...[
                      _OptionCard(
                        highlighted: !KycData.aadhaarVerified,
                        verified: KycData.aadhaarVerified,
                        icon: AadhaarIcon(
                          size: isSmallMobile ? 34 : 40,
                        ),
                        title: 'Aadhaar Verification',
                        subtitle:
                            'Verify your identity using Aadhaar card',
                        onTap: () {
                          Navigator.pushNamed(context, R.aadhaar);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // PAN card
                    _OptionCard(
                      highlighted: !panLocked,
                      locked: panLocked,
                      hint: panLocked
                          ? KycData.aadhaarFirstMessage
                          : null,
                      icon: PanIcon(
                        size: isSmallMobile ? 34 : 40,
                      ),
                      title: 'PAN Verification',
                      subtitle: 'Verify your identity using PAN card',
                      onTap: () => _openPan(context),
                    ),
                    const SizedBox(height: 16),

                    // Security information
                    WhiteCard(
                      color: C.lightGrey.withOpacity(0.8),
                      borderColor: C.border.withOpacity(0.7),
                      padding: EdgeInsets.all(
                        isSmallMobile ? 13 : 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: C.blue,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your data is safe with us',
                                  style: ts(
                                    13,
                                    w: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We use bank-grade security to protect your information.',
                                  style: ts(
                                    11.5,
                                    color: C.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Small bottom spacing; the scaffold manages the wave.
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final bool highlighted;
  final bool locked;
  final bool verified;
  final String? hint;
  final Widget icon;
  final String title;
  final String subtitle;
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallMobile = screenWidth <= 380;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: WhiteCard(
        color: locked ? C.lightGrey.withOpacity(0.7) : null,
        borderColor: highlighted ? C.blue : C.border.withOpacity(0.7),
        borderWidth: highlighted ? 1.5 : 1,
        padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: locked ? 0.45 : 1,
              child: IconBox(
                child: icon,
              ),
            ),
            SizedBox(width: isSmallMobile ? 10 : 14),

            // Flexible text area prevents overflow on narrow screens.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: ts(
                      isSmallMobile ? 13 : 15,
                      w: FontWeight.w700,
                      color: locked ? C.muted : C.navy,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: ts(
                      11.5,
                      color: C.muted,
                      height: 1.4,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      hint!,
                      style: ts(
                        10.5,
                        w: FontWeight.w600,
                        color: C.error,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Status indicator
            if (locked)
              const Icon(
                Icons.lock_outline_rounded,
                color: C.muted,
                size: 21,
              )
            else if (verified)
              const Icon(
                Icons.check_circle_rounded,
                color: C.green,
                size: 24,
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: C.navy,
                size: 25,
              ),
          ],
        ),
      ),
    );
  }
}
