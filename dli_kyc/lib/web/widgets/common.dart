import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/kyc_data.dart';
import '../theme.dart';

/// ---------------------------------------------------------------- Header
class KycHeader extends StatelessWidget {
  final bool showBack;
  final bool dark;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  const KycHeader({
    super.key,
    this.showBack = true,
    this.dark = false,
    this.onClose,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : C.navy;
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          if (showBack && !dark)
            Tooltip(
              message: 'Back',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.arrow_back, color: fg, size: 24),
                  ),
                ),
              ),
            ),
          if (showBack && !dark) const SizedBox(width: 8),
          const DliLogo(size: 38),
          const SizedBox(width: 10),
          Text('DLI',
              style: ts(24, w: FontWeight.w700, color: fg)),
          const Spacer(),
          if (dark)
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, color: Colors.white, size: 26),
            ),
        ],
      ),
    );
  }
}

/// Uploaded DLI app icon.
class DliLogo extends StatelessWidget {
  final double size;
  final bool white;
  const DliLogo({super.key, this.size = 38, this.white = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset('assets/images/app_icon.png',
          width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// ---------------------------------------------------------------- Page scaffold (website)
/// Real (unscaled) website layout. The card grows with the window up to a max
/// size and never gets smaller than a minimum size. When the window is smaller
/// than the minimum (for example after browser zoom-in) the page scrolls
/// vertically and horizontally.
class KycScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottom;
  final String? title;
  final double titleSize;
  final String? subtitle;
  final String rightTitle;
  final String rightText;
  final List<KycStepState> steps;
  /// If set, a back arrow is shown next to the logo and goes to the previous step.
  final String? backRoute;
  // kept for compatibility with the mobile screens (ignored on web)
  final bool wave;
  final bool showBack;

  const KycScaffold({
    super.key,
    required this.body,
    this.bottom,
    this.title,
    this.titleSize = 26,
    this.subtitle,
    this.rightTitle = '',
    this.rightText = '',
    this.steps = const [KycStepState.active, KycStepState.idle, KycStepState.idle],
    this.backRoute,
    this.wave = false,
    this.showBack = true,
  });

  @override
  State<KycScaffold> createState() => _KycScaffoldState();
}

class _KycScaffoldState extends State<KycScaffold> {
  final _h = ScrollController();
  final _v = ScrollController();

  @override
  void dispose() {
    _h.dispose();
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.lightGrey,
      body: LayoutBuilder(
        builder: (context, box) {
          const hMargin = 48.0;
          final cardW = (box.maxWidth - hMargin * 2).clamp(1060.0, 1400.0).toDouble();
          final cardH = (box.maxHeight - 110).clamp(800.0, 940.0).toDouble();
          final contentW = math.max(box.maxWidth, cardW + hMargin * 2);
          final contentH = math.max(box.maxHeight, cardH + 90);

          return Scrollbar(
            controller: _h,
            thumbVisibility: contentW > box.maxWidth,
            notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: _h,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentW,
                child: Scrollbar(
                  controller: _v,
                  thumbVisibility: contentH > box.maxHeight,
                  child: SingleChildScrollView(
                    controller: _v,
                    child: SizedBox(
                      height: contentH,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _card(cardW, cardH),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Secure', style: ts(13, color: C.muted)),
                                _dot(),
                                Text('Transparent', style: ts(13, color: C.muted)),
                                _dot(),
                                Text('Efficient', style: ts(13, color: C.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: C.navy.withOpacity(0.10),
              blurRadius: 40,
              offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(child: _left()),
            Expanded(child: _right()),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(color: C.blue, shape: BoxShape.circle),
      );

  Widget _left() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(64, 34, 64, 36),
      child: LayoutBuilder(
        builder: (context, box) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KycHeader(
              showBack: widget.backRoute != null,
              onBack: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (widget.backRoute != null) {
                  Navigator.pushReplacementNamed(context, widget.backRoute!);
                }
              },
            ),
            const SizedBox(height: 14),
            if (widget.title != null)
              Text(widget.title!,
                  style: ts(widget.titleSize, w: FontWeight.w800)),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(widget.subtitle!, style: ts(13.5, color: C.muted)),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(width: box.maxWidth, child: widget.body),
              ),
            ),
            if (widget.bottom != null) ...[
              const SizedBox(height: 12),
              widget.bottom!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _right() {
    return Container(
      color: C.lightGrey,
      child: Stack(
        children: [
          Positioned(
            right: -100,
            top: -195,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: -140,
            bottom: -240,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(58, 60, 76, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.rightTitle,
                    style: ts(34, w: FontWeight.w800, height: 1.25)),
                const SizedBox(height: 14),
                Text(widget.rightText,
                    style: ts(15, color: C.muted, height: 1.6)),
                const SizedBox(height: 28),
                _StatusCard(steps: widget.steps),
                const Spacer(),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: const [
                    _Chip(icon: Icons.verified_user_rounded, text: 'Bank-grade security'),
                    _Chip(icon: Icons.lock_outline, text: 'Encrypted'),
                    _Chip(icon: Icons.visibility_off_outlined, text: 'Private'),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: C.border.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: C.blue),
          const SizedBox(width: 7),
          Text(text, style: ts(12.5, w: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final List<KycStepState> steps;
  const _StatusCard({required this.steps});

  static const names = ['Aadhaar Verification', 'PAN Verification', 'Review & Submit'];
  static const subs = [
    'Verify using Aadhaar OTP',
    'Verify using PAN number',
    'Confirm your details',
  ];

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    // An organization verifies PAN only: the Aadhaar row is not shown.
    final from = KycData.isOrganization ? 1 : 0;
    for (int i = from; i < 3; i++) {
      final s = steps[i];
      final label = s == KycStepState.done
          ? 'Completed'
          : s == KycStepState.active
              ? 'In progress'
              : 'Pending';
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            _circle(i - from, s),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(names[i], style: ts(15, w: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('$label \u00b7 ${subs[i]}',
                      style: ts(12.5,
                          w: s == KycStepState.active
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: s == KycStepState.active ? C.blue : C.muted)),
                ],
              ),
            ),
          ],
        ),
      ));
      if (i < 2) rows.add(Divider(height: 1, color: C.border.withOpacity(0.6)));
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border.withOpacity(0.8)),
      ),
      child: Column(children: rows),
    );
  }

  Widget _circle(int i, KycStepState s) {
    if (s == KycStepState.idle) {
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: C.border),
        ),
        child: Text('${i + 1}', style: ts(13, w: FontWeight.w700)),
      );
    }
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: C.blue,
        shape: BoxShape.circle,
        boxShadow: s == KycStepState.active
            ? [BoxShadow(color: C.blue.withOpacity(0.22), spreadRadius: 4)]
            : null,
      ),
      child: s == KycStepState.done
          ? const Icon(Icons.check, color: Colors.white, size: 17)
          : Text('${i + 1}',
              style: ts(13, w: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// ---------------------------------------------------------------- Stepper
enum KycStepState { done, active, idle }

class KycStepper extends StatelessWidget {
  final List<KycStepState> states; // 3 items: Aadhaar, PAN, Review
  final List<bool> lines; // 2 items, true = blue line
  const KycStepper({super.key, required this.states, required this.lines});

  static const _allLabels = ['Aadhaar', 'PAN', 'Review'];

  // An organization verifies PAN only, so the Aadhaar step is not shown.
  List<KycStepState> get _states =>
      KycData.isOrganization ? states.sublist(1) : states;
  List<bool> get _lines => KycData.isOrganization ? lines.sublist(1) : lines;
  List<String> get labels =>
      KycData.isOrganization ? _allLabels.sublist(1) : _allLabels;

  @override
  Widget build(BuildContext context) {
    final n = _states.length;
    final children = <Widget>[];
    for (int i = 0; i < n; i++) {
      children.add(_node(i));
      if (i < n - 1) {
        children.add(Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 19),
            child: Container(
              height: 2,
              color: _lines[i] ? C.blue : C.border.withOpacity(0.7),
            ),
          ),
        ));
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _node(int i) {
    final s = _states[i];
    Widget circle;
    if (s == KycStepState.idle) {
      circle = Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: C.border, width: 1),
        ),
        child: Text('${i + 1}', style: ts(14, w: FontWeight.w700)),
      );
    } else {
      circle = Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: C.blue,
          shape: BoxShape.circle,
          boxShadow: s == KycStepState.active
              ? [
                  BoxShadow(
                      color: C.blue.withOpacity(0.22),
                      spreadRadius: 4,
                      blurRadius: 0)
                ]
              : null,
        ),
        child: s == KycStepState.done
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text('${i + 1}',
                style: ts(14, w: FontWeight.w700, color: Colors.white)),
      );
    }
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          SizedBox(height: 38, child: Center(child: circle)),
          const SizedBox(height: 6),
          Text(labels[i], style: ts(12, color: C.muted)),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------- User type tabs
/// Normal User | Organization  (Light Grey tab background, Primary Blue active tab)
class UserTypeTabs extends StatelessWidget {
  final UserType value;
  final ValueChanged<UserType> onChanged;
  const UserTypeTabs({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: C.lightGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          _tab(UserType.normal, Icons.person_outline_rounded, 'Normal User'),
          _tab(UserType.organization, Icons.business_rounded, 'Organization'),
        ],
      ),
    );
  }

  Widget _tab(UserType type, IconData icon, String label) {
    final selected = value == type;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? C.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: C.blue.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : C.navy),
                const SizedBox(width: 8),
                Text(label,
                    style: ts(13.5,
                        w: FontWeight.w700,
                        color: selected ? Colors.white : C.navy)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------- Buttons / cards
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const PrimaryButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: C.blue.withOpacity(0.28),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: C.blue,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(text,
                style: ts(16, w: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderWidth;
  final Color? color;
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = C.border,
    this.borderWidth = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
              color: C.navy.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

/// Grey rounded square holding the Aadhaar / PAN icon.
class IconBox extends StatelessWidget {
  final Widget child;
  final double size;
  const IconBox({super.key, required this.child, this.size = 66});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: C.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// ---------------------------------------------------------------- Success check
class SuccessBadge extends StatelessWidget {
  final double size;
  const SuccessBadge({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.69;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: C.green.withOpacity(0.08),
        border: Border.all(color: C.green.withOpacity(0.25), width: 2),
      ),
      child: Container(
        width: inner,
        height: inner,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF22B573), Color(0xFF148A4B)],
          ),
          boxShadow: [
            BoxShadow(
                color: C.green.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Icon(Icons.check_rounded, color: Colors.white, size: inner * 0.55),
      ),
    );
  }
}

/// ---------------------------------------------------------------- Wave footer
class WaveFooter extends StatelessWidget {
  final bool dark;
  final double height;
  const WaveFooter({super.key, this.dark = false, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter(dark)),
    );
  }
}

class _WavePainter extends CustomPainter {
  final bool dark;
  _WavePainter(this.dark);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final back = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.22, h * 0.05, w * 0.55, h * 0.12, w * 0.75, h * 0.40)
      ..cubicTo(w * 0.88, h * 0.55, w * 0.95, h * 0.55, w, h * 0.45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final front = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.25, h * 0.45, w * 0.55, h * 0.55, w * 0.78, h * 0.70)
      ..cubicTo(w * 0.90, h * 0.78, w * 0.96, h * 0.76, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    if (dark) {
      canvas.drawPath(back, Paint()..color = const Color(0xFF3B73D8).withOpacity(0.65));
      canvas.drawPath(front, Paint()..color = const Color(0xFF2A5CC4).withOpacity(0.9));
      final line = Path()
        ..moveTo(0, h * 0.58)
        ..cubicTo(w * 0.22, h * 0.10, w * 0.55, h * 0.18, w * 0.75, h * 0.44)
        ..cubicTo(w * 0.88, h * 0.58, w * 0.95, h * 0.58, w, h * 0.48);
      canvas.drawPath(
          line,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.white.withOpacity(0.35));
    } else {
      canvas.drawPath(back, Paint()..color = const Color(0xFF4F86F0));
      canvas.drawPath(front, Paint()..color = C.navy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// ---------------------------------------------------------------- Icons (painted)
class AadhaarIcon extends StatelessWidget {
  final double size;
  final Color arcColor;
  final Color rayColor;
  const AadhaarIcon({
    super.key,
    this.size = 40,
    this.arcColor = const Color(0xFFE53935),
    this.rayColor = const Color(0xFFF5A623),
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AadhaarPainter(arcColor, rayColor)));
}

class _AadhaarPainter extends CustomPainter {
  final Color arc, ray;
  _AadhaarPainter(this.arc, this.ray);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final cx = w / 2;
    final cy = s.height * 0.62;
    final stroke = w * 0.065;

    final arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    for (final r in [0.36, 0.27, 0.18]) {
      final rr = w * r;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: rr),
          math.pi, math.pi, false, arcPaint);
      canvas.drawLine(Offset(cx - rr, cy), Offset(cx - rr, cy + w * 0.20), arcPaint);
      canvas.drawLine(Offset(cx + rr, cy), Offset(cx + rr, cy + w * 0.20), arcPaint);
    }
    canvas.drawLine(Offset(cx, cy - w * 0.04), Offset(cx, cy + w * 0.20), arcPaint);

    final rayPaint = Paint()
      ..color = ray
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.9
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 7; i++) {
      final a = math.pi * (1.0 + i / 6.0);
      final p1 = Offset(cx + math.cos(a) * w * 0.44, cy + math.sin(a) * w * 0.44);
      final p2 = Offset(cx + math.cos(a) * w * 0.54, cy + math.sin(a) * w * 0.54);
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class PanIcon extends StatelessWidget {
  final double size;
  const PanIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.75,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final f in [0.9, 0.65, 0.5]) ...[
                  FractionallySizedBox(
                    widthFactor: f,
                    child: Container(
                      height: size * 0.055,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  SizedBox(height: size * 0.07),
                ]
              ],
            ),
          ),
          Container(
            width: size * 0.2,
            height: size * 0.32,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(3)),
          ),
        ],
      ),
    );
  }
}

/// Small QR-like pattern used on the card illustrations.
class QrMark extends StatelessWidget {
  final double size;
  const QrMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _QrPainter()));
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.black;
    final u = s.width / 9;
    void finder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, 3 * u, 3 * u), p);
      canvas.drawRect(Rect.fromLTWH((x + 0.6) * u, (y + 0.6) * u, 1.8 * u, 1.8 * u),
          Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH((x + 1) * u, (y + 1) * u, 1 * u, 1 * u), p);
    }

    finder(0, 0);
    finder(6, 0);
    finder(0, 6);
    const cells = [
      [4, 0], [4, 1], [3, 2], [5, 2], [3, 4], [4, 4], [5, 3], [7, 4], [8, 4],
      [4, 6], [5, 6], [6, 6], [6, 7], [8, 7], [4, 8], [7, 8], [8, 8], [3, 6],
      [0, 4], [1, 4], [1, 5], [3, 7],
    ];
    for (final c in cells) {
      canvas.drawRect(Rect.fromLTWH(c[0] * u, c[1] * u, u, u), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Person avatar used on the card illustrations.
class Avatar extends StatelessWidget {
  final double size;
  final Color bg;
  const Avatar({super.key, this.size = 82, this.bg = C.lightGrey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              top: size * 0.2,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration:
                    const BoxDecoration(color: C.navy, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              bottom: -size * 0.22,
              child: Container(
                width: size * 0.62,
                height: size * 0.5,
                decoration: const BoxDecoration(
                    color: C.navy, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
