import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _authToken;

  static Future<bool> login(String email, String password, bool isAdmin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'is_admin': isAdmin,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }
      throw Exception('Failed to load events');
    } catch (e) {
      print('Fetch events error: $e');
      rethrow;
    }
  }

  static Future<Event> createEvent(Event event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: _getHeaders(),
        body: jsonEncode(event.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Event.fromJson(data);
      }
      throw Exception('Failed to create event');
    } catch (e) {
      print('Create event error: $e');
      rethrow;
    }
  }

  static Future<Event> updateEvent(String id, Event event) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$id'),
        headers: _getHeaders(),
        body: jsonEncode(event.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Event.fromJson(data);
      }
      throw Exception('Failed to update event');
    } catch (e) {
      print('Update event error: $e');
      rethrow;
    }
  }

  static Future<void> deleteEvent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete event');
      }
    } catch (e) {
      print('Delete event error: $e');
      rethrow;
    }
  }

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static void clearAuth() {
    _authToken = null;
  }
}
