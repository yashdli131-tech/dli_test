import 'package:flutter/material.dart';
import '../../core/kyc_data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../../core/route_names.dart';
import 'pan_verified_screen.dart';

/// Screen 10 - KYC Completed
class KycCompletedScreen extends StatelessWidget {
  const KycCompletedScreen({super.key});

  Widget _dot(double l, double t, Color c, double s) => Positioned(
        left: l,
        top: t,
        child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      );

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF5A623);
    const green = Color(0xFF22B573);
    return KycScaffold(
      rightTitle: "You're all set",
      rightText:
          'Your KYC is complete. Head to your dashboard to start using DLI services.',
      steps: const [KycStepState.done, KycStepState.done, KycStepState.done],
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SuccessBadge(size: 150),
                _dot(34, 52, green, 7),
                _dot(10, 100, yellow, 6),
                _dot(60, 128, C.blue, 8),
                _dot(112, 6, yellow, 6),
                _dot(236, 18, C.green, 6),
                _dot(262, 62, C.blue, 8),
                _dot(268, 98, green, 6),
                _dot(238, 138, yellow, 7),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('KYC Completed!', style: ts(32, w: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            'Your identity has been successfully verified.\nYou can now access all our services.',
            textAlign: TextAlign.center,
            style: ts(14.5, color: C.muted, height: 1.55),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            text: 'Go to Dashboard',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, R.dashboard, (r) => false);
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showDetails(context),
            child: Text('View KYC Details',
                style: ts(14, w: FontWeight.w700, color: C.blue)),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KYC Details', style: ts(18, w: FontWeight.w700)),
                const SizedBox(height: 16),
                const KycSummaryCard(showAadhaar: true, showPanDate: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Replace with your real dashboard screen.
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DliLogo(size: 72),
              const SizedBox(height: 16),
              Text('Dashboard', style: ts(24, w: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Connect your dashboard screen here.',
                  style: ts(13, color: C.muted)),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  KycData.reset();
                  Navigator.pushNamedAndRemoveUntil(
                      context, R.home, (r) => false);
                },
                child: Text('Restart KYC demo',
                    style: ts(14, w: FontWeight.w700, color: C.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
