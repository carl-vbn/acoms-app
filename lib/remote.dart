import 'dart:convert';
import 'dart:developer';
import 'package:acoms_app/models/stats.dart';

import 'models/service.dart';
import 'package:http/http.dart' as http;

class Services {
  final Remote _remote;
  List<Service> _cache = [];

  Services(this._remote);

  Future<List<Service>> retrieve({bool skipCache = false}) async {
    if (skipCache || _cache.isEmpty) {
      final [serviceData, statusData] = await Future.wait([
        _remote.fetchServiceData(),
        _remote.fetchStatusData()
      ]);
      if (serviceData != null) {
        _cache = serviceData.entries
            .map((s) => Service(
                  id: s.key,
                  name: s.value['name'],
                  description: s.value['description'],
                  host: s.value['host'],
                  https: s.value['https'] ?? false,
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

class Stats {
  final Remote _remote;

  Stats(this._remote);

  Future<StatsSlice> retrieveStats(String serviceId, int sliceStart, int sliceEnd) async {
    final statsData = await _remote._get('stats/$serviceId?start=$sliceStart&end=$sliceEnd');
    if (statsData != null) {
      return StatsSlice(
        sliceStart: statsData['slice_start'],
        sliceEnd: statsData['slice_end'],
        sessionCount: statsData['session_count'],
        actorCount: statsData['actor_count'],
        sessionsPerActor: statsData['sessions_per_actor'].toDouble(),
        viewsPerSession: statsData['views_per_session'].toDouble(),
        pageViewsPerDay: statsData['page_views_per_day'] != null ? List<int>.from(statsData['page_views_per_day']) : null,
        uniqueActorsPerDay: statsData['unique_actors_per_day'] != null ? List<int>.from(statsData['unique_actors_per_day']) : null,
      );
    } else {
      log('Failed to fetch stats data for service $serviceId');
      throw Exception('Failed to fetch stats data');
    }
  }
}

class Remote {
  static const String apiBaseUrl = 'https://acoms.carl-vbn.dev';
  late String apiKey;
  late Services services;
  late Stats stats;

  Remote() {
    apiKey = const String.fromEnvironment('API_KEY');
    services = Services(this);
    stats = Stats(this);
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
