import 'dart:convert';
import 'dart:developer';
import 'models/service.dart';
import 'package:http/http.dart' as http;

class Services {
  final Remote remote;
  List<Service> _cache = [];

  Services(this.remote);

  Future<List<Service>> retrieve({bool skipCache = false}) async {
    if (skipCache || _cache.isEmpty) {
      final [serviceData, statusData] = await Future.wait([
        remote.fetchServiceData(),
        remote.fetchStatusData()
      ]);
      if (serviceData != null) {
        _cache = serviceData.entries
            .map((s) => Service(
                  id: s.key,
                  name: s.value['name'],
                  description: s.value['description'],
                  host: s.value['host'],
                  status: statusData?[s.key] ?? 'unknown',
                ))
            .toList();
      } else {
        log('Failed to fetch service data');
      }
    }
    return _cache;
  }
}

class Remote {
  static const String apiBaseUrl = 'https://acoms.carl-vbn.dev';
  late String apiKey;
  late Services services;

  Remote() {
    apiKey = const String.fromEnvironment('API_KEY');
    services = Services(this);
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
