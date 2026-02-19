import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // ── Session Management ──────────────────────────────────────────
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  static Future<void> saveSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', session);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
  }

  static Future<Map<String, String>> _headers() async {
    final session = await getSession();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (session != null) {
      headers['Authorization'] = 'Bearer $session';
    }
    return headers;
  }

  // ── Auth ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String userName, String userPass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'userPass': userPass,
        'clientType': 'MOBILE',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['responseCode'] == 0 && body['session'] != null) {
      await saveSession(body['session']);
    }
    return body;
    return body;
  }

  static Future<Map<String, dynamic>> loginSocial(String provider, String token, String? email, String? name, String? photoUrl) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login/social'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': provider,
        'token': token,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'clientType': 'MOBILE',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['responseCode'] == 0 && body['session'] != null) {
      await saveSession(body['session']);
    }
    return body;
  }


  static Future<Map<String, dynamic>> register(String userName, String userPass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/registerUser'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'userPass': userPass,
        'userType': 'USER',
        'companyName': '',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['responseCode'] == 0 && body['session'] != null) {
      await saveSession(body['session']);
    }
    return body;
  }

  // ── User ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // Network error or parsing error
    }
    return null;
  }

  // ── Challenges (for runners) ────────────────────────────────────
  static Future<List<dynamic>> getChallenges() async {
    final res = await http.get(
      Uri.parse('$baseUrl/challenges'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<Map<String, dynamic>> acceptChallenge(int tokenId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/challenge/accept'),
      headers: await _headers(),
      body: jsonEncode({'tokenId': tokenId}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Run ─────────────────────────────────────────────────────────
  static Future<void> saveRun(double distance, List<Map<String, double>> route) async {
    await http.post(
      Uri.parse('$baseUrl/run'),
      headers: await _headers(),
      body: jsonEncode({'distance': distance, 'route': route}),
    );
  }

  static Future<Map<String, dynamic>> getTotalDistance() async {
    final res = await http.get(
      Uri.parse('$baseUrl/runs/total-distance'),
      headers: await _headers(),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyRewards() async {
    final res = await http.get(
      Uri.parse('$baseUrl/my-rewards'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }
}
