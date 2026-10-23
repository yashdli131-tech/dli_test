import 'package:flutter/foundation.dart';

/// Who is doing the KYC.
///  normal       -> Aadhaar first, then PAN
///  organization -> PAN only
enum UserType { normal, organization }

/// Simple in-memory holder for the values collected during the KYC flow.
/// Replace the demo values with real FastAPI responses when you connect the backend.
///
/// [changes] notifies the screens when the user type or the Aadhaar / PAN
/// status changes, so the first page updates by itself.
class KycData {
  static final ValueNotifier<int> _tick = ValueNotifier<int>(0);
  static Listenable get changes => _tick;
  static void _notify() => _tick.value++;

  static const String aadhaarFirstMessage =
      'Please verify identity using Aadhaar card first';

  // ---- who is verifying
  static UserType _userType = UserType.normal;
  static UserType get userType => _userType;
  static set userType(UserType v) {
    if (_userType == v) return;
    _userType = v;
    _notify();
  }

  static bool get isOrganization => _userType == UserType.organization;

  // ---- values
  static String aadhaar = ''; // 12 digits, no spaces
  static String aadhaarClientId = '';
  static String aadhaarOtp = '';
  static String? aadhaarError;
  static String pan = '';
  static String panMasked = '';
  static String? panError;
  static String aadhaarName = 'Rahul Sharma'; // demo value
  static String aadhaarDateOfBirth = '';
  static String aadhaarGender = '';
  static String aadhaarAddress = '';
  static const String aadhaarMobile = '6359190929';
  static String panName = 'Rahul Sharma'; // demo value
  static String panDateOfBirth = '';

  // ---- status
  static bool _aadhaarVerified = false;
  static bool get aadhaarVerified => _aadhaarVerified;
  static set aadhaarVerified(bool v) {
    _aadhaarVerified = v;
    _notify();
  }

  static bool _panVerified = false;
  static bool get panVerified => _panVerified;
  static set panVerified(bool v) {
    _panVerified = v;
    _notify();
  }

  /// An organization verifies PAN directly.
  /// A normal user must finish the Aadhaar verification first.
  static bool get canVerifyPan => isOrganization || aadhaarVerified;

  static String get aadhaarMasked {
    if (aadhaar.length < 4) return 'XXXX XXXX 1234';
    return 'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';
  }

  static String get panValue => panMasked.isNotEmpty
      ? panMasked
      : (pan.isEmpty ? 'ABCDE1234F' : pan);

  /// Clears the verification progress. The chosen user type is kept.
  static void reset() {
    aadhaar = '';
    aadhaarClientId = '';
    aadhaarOtp = '';
    aadhaarError = null;
    aadhaarDateOfBirth = '';
    aadhaarGender = '';
    aadhaarAddress = '';
    pan = '';
    panMasked = '';
    panError = null;
    panDateOfBirth = '';
    _aadhaarVerified = false;
    _panVerified = false;
    _notify();
  }
}






