import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://card-display-server-go.onrender.com';

/// Helper: GET with basic error handling
Future<Map<String, dynamic>> getJson(Uri uri) async {
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 25));
    final decoded = json.decode(res.body);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (e) {
    return {'error': e.toString()};
  }
}

/// Helper: POST JSON
Future<Map<String, dynamic>> postJson(
  Uri uri,
  Map<String, dynamic> body,
) async {
  try {
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    final decoded = json.decode(res.body);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (e) {
    return {'error': e.toString()};
  }
}
