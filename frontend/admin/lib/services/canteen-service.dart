import 'dart:convert';
import 'package:http/http.dart' as http;

class CanteenService {
  final String baseUrl;

  CanteenService({this.baseUrl = "http://10.0.2.2:8080"});

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
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        if (responseData.containsKey('accessToken') && responseData.containsKey('refreshToken')) {
          return responseData;
        } else {
          return {"isOk":false,"error":'Error while exchanging data to server.'};
        }
      } else {
        return {"isOk":false,"error":responseData['error']};
      }
    } catch (e) {
      print("Login failed : ${e.toString()}");
      return {"isOk":false,"error":"Some error occurred while fulfilling your request."};
    }
  }
  Future<Map<String, dynamic>> name(String email, String password) async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({

        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {"isOk":false,"error":"Some error occurred while fulfilling your request."};
      }
    } catch (e) {
      print("Login failed : ${e.toString()}");
      return {"isOk":false,"error":"Some error occurred while fulfilling your request."};
    }
  }
}
