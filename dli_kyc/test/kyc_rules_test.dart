import 'package:dli_kyc/core/kyc_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    KycData.userType = UserType.normal;
    KycData.reset();
  });

  test('normal user: PAN is locked until Aadhaar is verified', () {
    expect(KycData.isOrganization, false);
    expect(KycData.canVerifyPan, false);

    KycData.aadhaarVerified = true;
    expect(KycData.canVerifyPan, true);
  });

  test('organization: PAN is open without Aadhaar', () {
    KycData.userType = UserType.organization;
    expect(KycData.isOrganization, true);
    expect(KycData.aadhaarVerified, false);
    expect(KycData.canVerifyPan, true);
  });

  test('reset clears the progress but keeps the chosen user type', () {
    KycData.userType = UserType.organization;
    KycData.aadhaarVerified = true;
    KycData.pan = 'ABCDE1234F';
    KycData.panVerified = true;

    KycData.reset();

    expect(KycData.aadhaarVerified, false);
    expect(KycData.panVerified, false);
    expect(KycData.pan, '');
    expect(KycData.userType, UserType.organization);
  });

  test('screens are told when the user type or Aadhaar status changes', () {
    var calls = 0;
    void listener() => calls++;
    KycData.changes.addListener(listener);

    KycData.userType = UserType.organization;
    KycData.aadhaarVerified = true;
    KycData.userType = UserType.organization; // same value: no notification

    KycData.changes.removeListener(listener);
    expect(calls, 2);
  });
}
