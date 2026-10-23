import 'package:flutter/material.dart';
import 'core/kyc_data.dart';
import 'core/kyc_service.dart';
import 'core/route_names.dart';
import 'core/theme.dart';
import 'responsive.dart';
import 'mobile/screens/aadhaar_details_screen.dart' as m;
import 'mobile/screens/aadhaar_otp_screen.dart' as m;
import 'mobile/screens/aadhaar_verified_screen.dart' as m;
import 'mobile/screens/kyc_completed_screen.dart' as m;
import 'mobile/screens/kyc_home_screen.dart' as m;
import 'mobile/screens/pan_screen.dart' as m;
import 'mobile/screens/pan_verified_screen.dart' as m;
import 'mobile/screens/verifying_screen.dart' as m;
import 'web/screens/aadhaar_details_screen.dart' as w;
import 'web/screens/aadhaar_otp_screen.dart' as w;
import 'web/screens/aadhaar_verified_screen.dart' as w;
import 'web/screens/kyc_completed_screen.dart' as w;
import 'web/screens/kyc_home_screen.dart' as w;
import 'web/screens/pan_screen.dart' as w;
import 'web/screens/pan_verified_screen.dart' as w;
import 'web/screens/verifying_screen.dart' as w;

class _Page {
  final String title; // browser tab title
  final Widget child;
  const _Page(this.title, this.child);
}

String _clean(String? raw) {
  var name = Uri.parse(raw ?? '/').path;
  if (name.length > 1 && name.endsWith('/')) {
    name = name.substring(0, name.length - 1);
  }
  if (name == '/' || name.isEmpty) return R.home;
  return name;
}

/// If a step is opened directly (typed URL / refresh) without the earlier
/// steps done, send the user back to the step they need first.
String? _redirectFor(String name) {
  // An organization verifies PAN only - the Aadhaar steps are not for it.
  if (KycData.isOrganization &&
      (name == R.aadhaar ||
          name == R.aadhaarOtp ||
          name == R.aadhaarVerifying ||
          name == R.aadhaarVerified)) {
    return R.home;
  }
  // PAN is locked for a normal user until the Aadhaar is verified.
  if (!KycData.canVerifyPan &&
      (name == R.pan ||
          name == R.panDetails ||
          name == R.panVerifying ||
          name == R.panVerified)) {
    return R.home;
  }
  switch (name) {
    case R.aadhaarOtp:
    case R.aadhaarVerifying:
      return KycData.aadhaar.length == 12 ? null : R.aadhaar;
    case R.aadhaarVerified:
      return KycData.aadhaarVerified ? null : R.aadhaar;
    case R.panDetails:
      return null; // allowed by the PAN lock above
    case R.panVerifying:
      return KycData.pan.isNotEmpty ? null : R.pan;
    case R.panVerified:
      return KycData.panVerified ? null : R.pan;
    case R.completed:
      return KycData.panVerified ? null : R.home;
  }
  return null;
}

Future<void> _verifyAadhaarTask() async {
  await KycService.verifyAadhaarOtp(
    clientId: KycData.aadhaarClientId,
    otp: KycData.aadhaarOtp,
  );
  KycData.aadhaarVerified = true;
}

Future<void> _verifyPanTask() async {
  await KycService.verifyPan();
  KycData.panVerified = true;
}

/// Every step = one mobile screen + one website screen, chosen by window width.
_Page? _pageFor(String name) {
  switch (name) {
    case R.home:
      return _Page(
        'KYC Verification | DLI',
        ResponsivePage(
          mobile: (_) => const m.KycHomeScreen(),
          web: (_) => const w.KycHomeScreen(),
        ),
      );
    case R.aadhaar:
      return _Page(
        'Aadhaar Details | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.AadhaarDetailsScreen(),
          web: (_) => const w.AadhaarDetailsScreen(),
        ),
      );
    case R.aadhaarOtp:
      return _Page(
        'Aadhaar OTP Verification | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.AadhaarOtpScreen(),
          web: (_) => const w.AadhaarOtpScreen(),
        ),
      );
    case R.aadhaarVerifying:
      return _Page(
        'Verifying Aadhaar | DLI KYC',
        ResponsivePage(
          mobile: (_) => m.VerifyingScreen(
            type: m.VerifyType.aadhaar,
            task: _verifyAadhaarTask,
            nextRoute: R.aadhaarVerified,
          ),
          web: (_) => w.VerifyingScreen(
            type: w.VerifyType.aadhaar,
            task: _verifyAadhaarTask,
            nextRoute: R.aadhaarVerified,
          ),
        ),
      );
    case R.aadhaarVerified:
      return _Page(
        'Aadhaar Verified | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.AadhaarVerifiedScreen(),
          web: (_) => const w.AadhaarVerifiedScreen(),
        ),
      );
    case R.pan:
      return _Page(
        'PAN Verification | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.PanScreen(showCard: false),
          web: (_) => const w.PanScreen(showCard: false),
        ),
      );
    case R.panDetails:
      return _Page(
        'PAN Details | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.PanScreen(showCard: true),
          web: (_) => const w.PanScreen(showCard: true),
        ),
      );
    case R.panVerifying:
      return _Page(
        'Verifying PAN | DLI KYC',
        ResponsivePage(
          mobile: (_) => m.VerifyingScreen(
            type: m.VerifyType.pan,
            task: _verifyPanTask,
            nextRoute: R.panVerified,
          ),
          web: (_) => w.VerifyingScreen(
            type: w.VerifyType.pan,
            task: _verifyPanTask,
            nextRoute: R.panVerified,
          ),
        ),
      );
    case R.panVerified:
      return _Page(
        'Review & Confirm | DLI KYC',
        ResponsivePage(
          mobile: (_) => const m.PanVerifiedScreen(),
          web: (_) => const w.PanVerifiedScreen(),
        ),
      );
    case R.completed:
      return _Page(
        'KYC Completed | DLI',
        ResponsivePage(
          mobile: (_) => const m.KycCompletedScreen(),
          web: (_) => const w.KycCompletedScreen(),
        ),
      );
    case R.dashboard:
      return _Page(
        'Dashboard | DLI',
        ResponsivePage(
          mobile: (_) => const m.DashboardPlaceholder(),
          web: (_) => const w.DashboardPlaceholder(),
        ),
      );
  }
  return null;
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  var name = _clean(settings.name);
  final redirect = _redirectFor(name);
  if (redirect != null) name = redirect;
  final page = _pageFor(name) ?? _pageFor(R.home)!;
  if (_pageFor(name) == null) name = R.home;
  return MaterialPageRoute(
    settings: RouteSettings(name: name),
    builder: (_) => Title(title: page.title, color: C.navy, child: page.child),
  );
}

