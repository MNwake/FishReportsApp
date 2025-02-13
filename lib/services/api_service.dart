import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/survey.dart';
import '../models/species.dart';
import '../models/county.dart';

class ApiService {
  static const String baseUrl = 'https://koesterventures.com/fish-reports';

  Future<List<FishData>> getSurveyData({
    String? species,
    String? minYear,
    String? maxYear,
    List<String>? counties,
    String? sortBy,
    String? order,
    String? search,
    bool gameFishOnly = false,
    int limit = 10,
    int page = 1,
  }) async {
    final queryParams = {
      if (species != null) 'species': species,
      if (minYear != null) 'minYear': minYear,
      if (maxYear != null) 'maxYear': maxYear,
      if (counties != null && counties.isNotEmpty) 'county': counties.join(','),
      if (sortBy != null) 'sort_by': sortBy,
      if (order != null) 'order': order,
      if (search != null) 'search': search,
      if (gameFishOnly) 'game_fish': 'true',
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final uri = Uri.parse('$baseUrl/data').replace(queryParameters: queryParams);
    print('URI: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = jsonData['data'] as List;
      
      return dataList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return FishData.fromJson(item);
          }
          print('Invalid item format: $item');
          return null;
        } catch (e) {
          print('Error parsing FishData: $e');
          print('Problem item: $item');
          return null;
        }
      }).whereType<FishData>().toList();
    } else {
      throw Exception('Failed to load survey data: ${response.statusCode}');
    }
  }

  Future<List<Species>> getSpecies() async {
    final uri = Uri.parse('$baseUrl/species');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['data'] == null) return [];
      
      final List<dynamic> dataList = jsonData['data'] as List;
      return dataList.map((item) {
        if (item is! Map<String, dynamic>) {
          print('Invalid species format: $item');
          return null;
        }
        try {
          return Species.fromJson(item);
        } catch (e) {
          print('Error parsing Species: $e');
          return null;
        }
      }).whereType<Species>().toList();
    } else {
      throw Exception('Failed to load species');
    }
  }

  Future<List<County>> getCounties() async {
    final uri = Uri.parse('$baseUrl/counties');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['data'] == null) return [];
      
      final List<dynamic> dataList = jsonData['data'] as List;
      return dataList.map((item) {
        if (item is! Map<String, dynamic>) {
          print('Invalid county format: $item');
          return null;
        }
        try {
          return County.fromJson(item);
        } catch (e) {
          print('Error parsing County: $e');
          return null;
        }
      }).whereType<County>().toList();
    } else {
      throw Exception('Failed to load counties');
    }
  }

  Future<Map<String, dynamic>> getGraphData({
    required String dow,
    required String species,
    required String date,
  }) async {
    final uri = Uri.parse('$baseUrl/graph').replace(queryParameters: {
      'dow': dow,
      'species': species,
      'date': date,
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load graph data');
    }
  }

  // Helper method to build query parameters consistently
  Uri _buildUri(String path, {
    List<String>? species,
    List<String>? county,
    List<String>? lake,
    String? minYear,
    String? maxYear,
    bool gameFishOnly = false,
    String? sortBy,
    String? order,
    int? limit,
    int? page,
  }) {
    final baseUri = Uri.parse('$baseUrl/$path');
    final pairs = <String>[];
    
    // Add list parameters as repeated keys
    species?.forEach((s) => pairs.add('species=$s'));
    county?.forEach((c) => pairs.add('county=$c'));
    lake?.forEach((l) => pairs.add('lake=$l'));
    
    // Add single value parameters
    if (minYear != null) pairs.add('minYear=$minYear');
    if (maxYear != null) pairs.add('maxYear=$maxYear');
    if (gameFishOnly) pairs.add('game_fish=true');
    if (sortBy != null) pairs.add('sort_by=$sortBy');
    if (order != null) pairs.add('order=$order');
    if (limit != null) pairs.add('limit=$limit');
    if (page != null) pairs.add('page=$page');
    
    return Uri.parse('$baseUri${pairs.isNotEmpty ? '?' : ''}${pairs.join('&')}');
  }

  Future<List<FishData>> getRecentSurveys({
    List<String>? species,
    List<String>? county,
    List<String>? lake,
    String? minYear,
    String? maxYear,
    bool gameFishOnly = false,
  }) async {
    final uri = _buildUri(
      'data',
      species: species,
      county: county,
      lake: lake,
      minYear: minYear,
      maxYear: maxYear,
      gameFishOnly: gameFishOnly,
      sortBy: 'survey_date',
      order: 'desc',
    );
    
    print('DEBUG: Making request to URI: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = jsonData['data'] as List;
      
      return dataList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return FishData.fromJson(item);
          }
          print('Invalid item format: $item');
          return null;
        } catch (e) {
          print('Error parsing FishData: $e');
          print('Problem item: $item');
          return null;
        }
      }).whereType<FishData>().toList();
    } else {
      throw Exception('Failed to load fish data');
    }
  }

  Future<List<FishData>> getBiggestFish({
    List<String>? species,
    List<String>? county,
    List<String>? lake,
    String? minYear,
    String? maxYear,
    bool gameFishOnly = false,
  }) async {
    final uri = _buildUri(
      'data',
      species: species,
      county: county,
      lake: lake,
      minYear: minYear,
      maxYear: maxYear,
      gameFishOnly: gameFishOnly,
      sortBy: 'max_length',
      order: 'desc',
      limit: 10,
      page: 1,
    );

    print('DEBUG: Making request to URI: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = jsonData['data'] as List;
      
      return dataList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return FishData.fromJson(item);
          }
          print('Invalid item format: $item');
          return null;
        } catch (e) {
          print('Error parsing FishData: $e');
          print('Problem item: $item');
          return null;
        }
      }).whereType<FishData>().toList();
    } else {
      throw Exception('Failed to load fish data');
    }
  }

  Future<List<FishData>> getMostCaught({
    List<String>? species,
    List<String>? county,
    List<String>? lake,
    String? minYear,
    String? maxYear,
    bool gameFishOnly = false,
  }) async {
    final uri = _buildUri(
      'data',
      species: species,
      county: county,
      lake: lake,
      minYear: minYear,
      maxYear: maxYear,
      gameFishOnly: gameFishOnly,
      sortBy: 'total_catch',
      order: 'desc',
      limit: 10,
      page: 1,
    );

    print('DEBUG: Making request to URI: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = jsonData['data'] as List;
      
      return dataList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return FishData.fromJson(item);
          }
          print('Invalid item format: $item');
          return null;
        } catch (e) {
          print('Error parsing FishData: $e');
          print('Problem item: $item');
          return null;
        }
      }).whereType<FishData>().toList();
    } else {
      throw Exception('Failed to load fish data');
    }
  }
} 