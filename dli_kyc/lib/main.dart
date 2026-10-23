import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app_router.dart';
import 'core/route_names.dart';
import 'core/theme.dart';

void main() {
  // clean URLs on the web: /kyc/aadhaar instead of /#/kyc/aadhaar
  if (kIsWeb) usePathUrlStrategy();
  runApp(const DliKycApp());
}

class DliKycApp extends StatelessWidget {
  const DliKycApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYC Verification | DLI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Fixed text size on every screen (same as both original projects).
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      initialRoute: R.home,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: (s) => onGenerateRoute(RouteSettings(name: R.home)),
    );
  }
}
