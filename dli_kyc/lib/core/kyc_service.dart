import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'kyc_data.dart';

class KycService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'KYC_API_BASE_URL',
    defaultValue: '',
  );

  static String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    }
    return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  }

  static Future<String> generateAadhaarOtp(String aadhaar) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/v1/aadhaar-v2/generate-otp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'id_number': aadhaar}),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodeResponse(response);
    final clientId = payload['client_id'];
    if (clientId is! String || clientId.isEmpty) {
      throw const KycApiException('The server did not return an OTP session.');
    }
    return clientId;
  }

  static Future<void> verifyAadhaarOtp({
    required String clientId,
    required String otp,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/v1/aadhaar-v2/submit-otp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'client_id': clientId, 'otp': otp}),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodeResponse(response);
    final profile = payload['profile'];
    if (payload['success'] != true || profile is! Map<String, dynamic>) {
      throw const KycApiException('Aadhaar verification was not confirmed.');
    }
    final name = profile['full_name'];
    if (name is String && name.isNotEmpty) KycData.aadhaarName = name;
    final dateOfBirth = profile['date_of_birth'];
    if (dateOfBirth is String) KycData.aadhaarDateOfBirth = dateOfBirth;
    final gender = profile['gender'];
    if (gender is String) KycData.aadhaarGender = gender;
    KycData.aadhaarAddress = [
      profile['address'],
      profile['city'],
      profile['state'],
      profile['pincode'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw KycApiException(
        'The verification server returned an invalid response (' +
            response.statusCode.toString() + ').',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const KycApiException('The verification server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded['detail'];
      throw KycApiException(
        detail is String
            ? detail
            : 'Aadhaar request failed (' + response.statusCode.toString() + ').',
      );
    }
    return decoded;
  }

  static Future<void> verifyPan() async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/v1/pan/pan-validation'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'id_number': KycData.pan}),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodeResponse(response);
    if (payload['success'] != true || payload['verification_status'] != 'mock_success') {
      throw const KycApiException('PAN verification was not confirmed.');
    }
    final name = payload['holder_name'];
    final maskedPan = payload['pan_masked'];
    if (name is String && name.isNotEmpty) KycData.panName = name;
    if (maskedPan is String && maskedPan.isNotEmpty) KycData.panMasked = maskedPan;
    final dateOfBirth = payload['date_of_birth_or_incorporation'];
    if (dateOfBirth is String) {
      final parsedDate = DateTime.tryParse(dateOfBirth);
      KycData.panDateOfBirth = parsedDate == null
          ? dateOfBirth
          : '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    }
  }
}

class KycApiException implements Exception {
  final String message;
  const KycApiException(this.message);

  @override
  String toString() => message;
}


