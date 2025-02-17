import 'dart:convert';
import 'package:http/http.dart' as http;

class CanteenService {
  final String baseUrl;

  CanteenService({this.baseUrl = "http://127.0.0.1:8080"});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('accessToken') && responseData.containsKey('refreshToken')) {
          return responseData;
        } else {
          throw Exception('Tokens not found in response');
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception('Login failed: ${errorResponse['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
