# DLI - KYC Verification (Flutter) - ONE project for mobile + website

Same 10 screens, same design as your two projects:

* `lib/mobile/`  - the MOBILE design (from dli_kyc_for_mobile.zip), unchanged
* `lib/web/`     - the WEBSITE design (from dli_kyc_web.zip), unchanged
* `lib/core/`    - shared: colours, KycData, KycService (FastAPI hook), route names
* `lib/app_router.dart` + `lib/responsive.dart` - pick mobile or website screen

Screens: 1 KYC Verification - 2 Aadhaar Details - 3 Aadhaar OTP - 4 Verifying Aadhaar
5 Aadhaar Verified - 6 PAN Details - 7 PAN Page - 8 Verifying PAN
9 PAN Verified / Review - 10 KYC Completed

## How it chooses the design
Window / screen width  < 800  -> mobile design (phone-size column, max 430 wide)
Window / screen width >= 800  -> website design
It switches live when the browser window is resized or the phone is rotated.
Change the number in `lib/responsive.dart` (kWebBreakpoint) if you want another limit.

## Run
Open a terminal in this folder (internet needed once for Poppins + packages):

    flutter create . --platforms=web,android,ios
    flutter pub get
    flutter run -d chrome        # website + mobile design (resize the window)
    flutter run                  # phone / emulator (mobile design)

`flutter create .` only adds the web/android/ios folders. It does not overwrite
lib/, pubspec.yaml or assets/.

Build for hosting:  flutter build web

## URLs (web, no `#`)
/kyc  /kyc/aadhaar  /kyc/aadhaar/otp  /kyc/aadhaar/verifying  /kyc/aadhaar/verified
/kyc/pan  /kyc/pan/details  /kyc/pan/verifying  /kyc/pan/verified
/kyc/completed  /dashboard
Hosting needs a "rewrite everything to index.html" rule (nginx: try_files $uri /index.html;).
After `flutter create .` set <title> in web/index.html to "KYC Verification | DLI".

## User types (first page)
The first page has two tabs: **Normal User** and **Organization** (`UserTypeTabs`).

| | Normal User | Organization |
|---|---|---|
| Cards on the first page | Aadhaar + PAN | PAN only |
| PAN card | locked (grey, lock icon, red text "Please verify identity using Aadhaar card first") until Aadhaar is verified; tapping it shows the same message | open |
| Stepper / progress panel | Aadhaar - PAN - Review | PAN - Review |
| Review page | Aadhaar + PAN details | PAN details |

The rules live in `lib/core/kyc_data.dart` (`userType`, `canVerifyPan`).
`lib/app_router.dart` enforces them for typed / refreshed URLs too:
a normal user without Aadhaar who opens /kyc/pan goes back to /kyc, and an
organization that opens /kyc/aadhaar goes back to /kyc.
The state is in memory only (like the rest of the demo data), so a browser
refresh starts again as Normal User. Save userType on the backend / local storage
when you connect FastAPI.

Tests: `flutter test` (test/kyc_rules_test.dart).

## Logo
assets/images/app_icon.png is used on every screen (replace the file to change it).

## Backend hook (UI only for now)
lib/core/kyc_service.dart: verifyAadhaar() and verifyPan(). The loaders wait for
these futures (both mobile and website), so call FastAPI there.
Demo name is in lib/core/kyc_data.dart.
