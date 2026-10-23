import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class KycTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final List<TextInputFormatter> formatters;
  final TextInputType keyboardType;
  final TextCapitalization capitalization;
  final String? error;
  final ValueChanged<String>? onChanged;

  const KycTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.formatters = const [],
    this.keyboardType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
    this.error,
    this.onChanged,
  });

  @override
  State<KycTextField> createState() => _KycTextFieldState();
}

class _KycTextFieldState extends State<KycTextField> {
  bool _obscure = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasError ? C.error : C.border, width: 1),
            boxShadow: [
              BoxShadow(
                  color: C.navy.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.capitalization,
            inputFormatters: widget.formatters,
            onChanged: widget.onChanged,
            style: ts(16, w: FontWeight.w500),
            cursorColor: C.blue,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: ts(16, color: C.muted.withOpacity(0.75)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: C.muted,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(widget.error!, style: ts(12, color: C.error)),
          ),
      ],
    );
  }
}

/// 1234 5678 9012
class AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final t = digits.length > 12 ? digits.substring(0, 12) : digits;
    final b = StringBuffer();
    for (int i = 0; i < t.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(t[i]);
    }
    final s = b.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
