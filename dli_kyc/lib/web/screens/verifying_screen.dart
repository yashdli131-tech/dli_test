import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/kyc_data.dart';
import '../../core/route_names.dart';
import '../theme.dart';
import '../widgets/common.dart';

enum VerifyType { aadhaar, pan }

/// Screens 4 and 8 - full screen loader (Verifying Aadhaar / Verifying PAN).
/// Waits for [task]; when it completes it opens the screen built by [next].
class VerifyingScreen extends StatefulWidget {
  final VerifyType type;
  final Future<void> Function() task;
  final String nextRoute;
  const VerifyingScreen({
    super.key,
    required this.type,
    required this.task,
    required this.nextRoute,
  });

  @override
  State<VerifyingScreen> createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<VerifyingScreen> {
  int _active = 0;
  Timer? _timer;

  bool get _isAadhaar => widget.type == VerifyType.aadhaar;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _active = (_active + 1) % 4);
    });
    widget.task().then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, widget.nextRoute);
    }).catchError((Object error) {
      if (!mounted) return;
      if (_isAadhaar) {
        KycData.aadhaarError = error.toString();
      } else {
        KycData.panError = error.toString();
      }
      final retryRoute = _isAadhaar
          ? R.aadhaarOtp
          : (KycData.isOrganization ? R.pan : R.panDetails);
      Navigator.pushReplacementNamed(context, retryRoute);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _isAadhaar ? 'Aadhaar' : 'PAN';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A3A63), Color(0xFF2653AB)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                  left: 0, right: 0, bottom: 0, child: WaveFooter(dark: true, height: 170)),
              LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    child: KycHeader(
                      dark: true,
                      showBack: false,
                      onClose: () {
                        KycData.reset();
                        Navigator.pushNamedAndRemoveUntil(context, R.home, (r) => false);
                      },
                    ),
                  ),
                  const Spacer(flex: 3),
                  _isAadhaar
                      ? const AadhaarIcon(
                          size: 112,
                          arcColor: Colors.white,
                          rayColor: Color(0xFFF5B63A),
                        )
                      : const _PanLoaderIcon(),
                  SizedBox(height: _isAadhaar ? 48 : 42),
                  Text('Verifying $name',
                      style: ts(34, w: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Please wait while we verify your $name details...',
                      textAlign: TextAlign.center,
                      style: ts(16,
                          color: Colors.white.withOpacity(0.8), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 46),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _active
                              ? Colors.white
                              : const Color(0xFF5B9BF5),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanLoaderIcon extends StatelessWidget {
  const _PanLoaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: SizedBox(
        width: 70,
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 46,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final w in [30.0, 22.0, 14.0]) ...[
                    Container(
                        width: w,
                        height: 3,
                        decoration: BoxDecoration(
                            color: const Color(0xFF7FB2FF),
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: Color(0xFF173A63), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF2ED573), size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


