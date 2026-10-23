import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API service for the local DLI mock Aadhaar and PAN backend.
///
/// The backend remains responsible for OTP checking, validation,
/// and saving records to PostgreSQL.
class KycApiService {
  KycApiService._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static const Duration _timeout = Duration(seconds: 20);

  // ----------------------------------------------------------
  // COMMON POST REQUEST
  // ----------------------------------------------------------

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    late final http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception(
        'The server took too long to respond. Please retry.',
      );
    } catch (error) {
      throw Exception(
        'Cannot connect to the DLI backend at $baseUrl. '
        'Check that FastAPI is running. Details: $error',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw Exception(
        'The server returned an invalid response '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response received from backend.');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final detail = decoded['detail'];

      throw Exception(
        detail?.toString() ??
            'Request failed with HTTP ${response.statusCode}.',
      );
    }

    return decoded;
  }

  // ----------------------------------------------------------
  // 1. GENERATE MOCK AADHAAR OTP
  // POST /api/v1/aadhaar-v2/generate-otp
  // ----------------------------------------------------------

  static Future<Map<String, dynamic>> generateAadhaarOtp(
    String aadhaarNumber,
  ) {
    return _post(
      '/api/v1/aadhaar-v2/generate-otp',
      {
        'id_number': aadhaarNumber.trim(),
      },
    );
  }

  // ----------------------------------------------------------
  // 2. SUBMIT MOCK AADHAAR OTP
  // POST /api/v1/aadhaar-v2/submit-otp
  //
  // The backend validates the OTP, runs mock validation,
  // saves the fictional profile, and returns that profile.
  // ----------------------------------------------------------

  static Future<Map<String, dynamic>> submitAadhaarOtp({
    required String clientId,
    required String otp,
  }) {
    return _post(
      '/api/v1/aadhaar-v2/submit-otp',
      {
        'client_id': clientId,
        'otp': otp.trim(),
      },
    );
  }

  // ----------------------------------------------------------
  // 3. MOCK PAN VALIDATION
  // POST /api/v1/pan/pan-validation
  // ----------------------------------------------------------

  static Future<Map<String, dynamic>> validatePan(
    String panNumber,
  ) {
    return _post(
      '/api/v1/pan/pan-validation',
      {
        'id_number': panNumber.trim().toUpperCase(),
      },
    );
  }
}