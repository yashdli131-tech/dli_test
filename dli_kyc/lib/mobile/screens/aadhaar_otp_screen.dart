import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/route_names.dart';
import '../../core/kyc_data.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Screen 3 - Aadhaar OTP
class AadhaarOtpScreen extends StatefulWidget {
  const AadhaarOtpScreen({super.key});

  @override
  State<AadhaarOtpScreen> createState() => _AadhaarOtpScreenState();
}

class _AadhaarOtpScreenState extends State<AadhaarOtpScreen> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  int _seconds = 24;
  Timer? _timer;
  String? _error = KycData.aadhaarError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _verify() {
    if (_otp.length != 6) {
      setState(() => _error = 'Please enter the 6-digit OTP');
      return;
    }
    KycData.aadhaarOtp = _otp;
    KycData.aadhaarError = null;
    Navigator.pushReplacementNamed(context, R.aadhaarVerifying);
  }

  String get _timeText =>
      '00:${_seconds.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return KycScaffold(
      title: 'Aadhaar OTP Verification',
      backRoute: R.aadhaar,
      bottom: PrimaryButton(text: 'Verify OTP', onTap: _verify),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KycStepper(
            states: [KycStepState.done, KycStepState.idle, KycStepState.idle],
            lines: [false, false],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: ts(14, color: C.navy, height: 1.5),
              children: [
                TextSpan(
                    text: 'Enter the OTP',
                    style: ts(14, w: FontWeight.w700)),
                const TextSpan(
                    text: ' sent to your mobile number\nlinked with Aadhaar.'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, _box),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: ts(12, color: C.error)),
            ),
          const SizedBox(height: 18),
          Center(
            child: _seconds > 0
                ? Text('Resend OTP in $_timeText',
                    style: ts(13, color: C.muted))
                : GestureDetector(
                    onTap: () {
                      setState(() => _seconds = 24);
                      _startTimer();
                    },
                    child: Text('Resend OTP',
                        style: ts(13, w: FontWeight.w700, color: C.blue)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _box(int i) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _ctrls[i].text.isEmpty &&
            i > 0) {
          _nodes[i - 1].requestFocus();
          _ctrls[i - 1].clear();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        width: 48,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _error != null && _ctrls[i].text.isEmpty
                  ? C.error
                  : C.border,
              width: 1),
          boxShadow: [
            BoxShadow(
                color: C.navy.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: TextField(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          autofocus: i == 0,
          textAlign: TextAlign.center,
          obscureText: true,
          keyboardType: TextInputType.number,
          style: ts(20, w: FontWeight.w500),
          cursorColor: C.blue,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (v) {
            setState(() => _error = null);
            if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
            if (v.isNotEmpty && i == 5) _nodes[i].unfocus();
          },
        ),
      ),
    );
  }
}

