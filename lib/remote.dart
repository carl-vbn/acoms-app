import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Remote {
  static const String apiBaseUrl = 'https://acoms.carl-vbn.dev';
  late String apiKey;

  Remote() {
    apiKey = const String.fromEnvironment('API_KEY');
  }

  Future<Map<String, dynamic>?> _get(String endpoint) async {
    late http.Response response;
    try {
      response = await http.get(
        Uri.parse('$apiBaseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
    } catch (e) {
      log('Error fetching data from $endpoint: $e');
      return null;
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      log('Error fetching data: ${response.statusCode}');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> fetchServiceData() async {
    return await _get('services');
  }

  Future<Map<String, dynamic>?> fetchStatusData() async {
    return await _get('status');
  }

  Future<Map<String, dynamic>?> fetchTerminalData() async {
    return await _get('terminals');
  }

  Future<bool> heartbeat() async {
    return await _get('heartbeat') != null;
  }
}
