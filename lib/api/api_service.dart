// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_model.dart';
//
// class ApiService {
//   final String baseUrl = "https://yourapi.com"; // Replace with your API base URL
//
//   // Login method
//   Future<User?> login(String username, String password) async {
//     final String url = "$baseUrl/login/";
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'username': username, 'password': password}),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final user = User.fromJson(data);
//
//         // Save tokens securely using SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('access_token', user.accessToken);
//         await prefs.setString('refresh_token', user.refreshToken);
//
//         return user;
//       } else {
//         // Handle non-200 responses
//         final errorData = jsonDecode(response.body);
//         throw Exception(errorData['detail'] ?? 'Login failed');
//       }
//     } catch (e) {
//       // Log the error and rethrow it
//       throw Exception('Error during login: $e');
//     }
//   }
//
//   // Get token securely
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access_token');
//   }
//
//   Future<String?> getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('refresh_token');
//   }
//
//   // Clear tokens
//   Future<void> clearTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('access_token');
//     await prefs.remove('refresh_token');
//   }
// }
