import 'package:flutter/material.dart';

/// Screens narrower than this use the MOBILE design (lib/mobile),
/// wider screens use the WEBSITE design (lib/web).
const double kWebBreakpoint = 800;

/// Picks the mobile or the website version of one screen from the window width,
/// and switches live when the window is resized or the phone is rotated.
class ResponsivePage extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder web;
  const ResponsivePage({super.key, required this.mobile, required this.web});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= kWebBreakpoint) return web(context);
        return _MobileFrame(width: box.maxWidth, child: mobile(context));
      },
    );
  }
}

/// Keeps the mobile design in a phone-size column when it is shown on a
/// wider screen (tablet / narrow browser window). Same frame as the original
/// mobile project.
class _MobileFrame extends StatelessWidget {
  final double width;
  final Widget child;
  const _MobileFrame({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EDF5),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width > 450 ? 28 : 0),
          child: child,
        ),
      ),
    );
  }
}
