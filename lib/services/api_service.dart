import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import '../models/survey.dart';
import '../models/species.dart';
import '../models/county.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:frontend/models/fish_data.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static const String baseUrl = 'https://koesterventures.com/fish-reports';

  Future<List<FishData>> getSurveyData({
    List<String>? species,
    List<String>? counties,
    List<String>? lakes,
    String? sortBy,
    String? order,
    String? minYear,
    String? maxYear,
    bool? gameFishOnly,
    int? limit = 50,
    int page = 1,
  }) async {
    print('DEBUG: getSurveyData called with:');
    print('  species: $species');
    print('  counties: $counties');
    print('  lakes: $lakes');
    print('  minYear: $minYear');
    print('  maxYear: $maxYear');
    print('  sortBy: $sortBy');
    print('  order: $order');
    print('  gameFishOnly: $gameFishOnly');
    print('  page: $page');

    // Start building the URL with base parameters
    var urlString = '$baseUrl/surveys?';
    
    // Add repeated parameters for arrays
    if (species?.isNotEmpty ?? false) {
      urlString += species!.map((s) => 'species=$s').join('&') + '&';
    }
    if (counties?.isNotEmpty ?? false) {
      urlString += counties!.map((c) => 'counties=$c').join('&') + '&';
    }
    if (lakes?.isNotEmpty ?? false) {
      urlString += lakes!.map((l) => 'lake=$l').join('&') + '&';
    }
    
    // Add the rest of the parameters
    final otherParams = <String, String>{
      if (sortBy != null) 'sort_by': sortBy,
      if (order != null) 'order': order,
      if (minYear != null) 'minYear': minYear,
      if (maxYear != null) 'maxYear': maxYear,
      if (gameFishOnly != null) 'game_fish': gameFishOnly.toString(),
      if (limit != null) 'limit': limit.toString(),
      'page': page.toString(),
    };
    
    urlString += otherParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    
    print('DEBUG: Final URI: $urlString');

    final response = await http.get(
      Uri.parse(urlString),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = jsonData['data'] as List;
      
      // If we get an empty data list and we're not on page 1, return empty list
      if (dataList.isEmpty && page > 1) {
        return [];
      }
      
      return dataList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return FishData.fromJson(item);
          }
          print('DEBUG: Invalid item format: $item');
          return null;
        } catch (e) {
          print('DEBUG: Error parsing FishData: $e');
          print('DEBUG: Problem item: $item');
          return null;
        }
      }).whereType<FishData>().toList();
    } else {
      print('DEBUG: Request failed with status: ${response.statusCode}');
      print('DEBUG: Error response body: ${response.body}');
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
    final baseUri = Uri.parse('$baseUrl/surveys');
    final pairs = <String>[];
    
    if (species?.isNotEmpty ?? false) pairs.add('species=${species!.join(',')}');
    if (county?.isNotEmpty ?? false) pairs.add('counties=${county!.join(',')}');
    if (lake?.isNotEmpty ?? false) pairs.add('lake=${lake!.join(',')}');
    
    if (minYear != null) pairs.add('minYear=$minYear');
    if (maxYear != null) pairs.add('maxYear=$maxYear');
    if (gameFishOnly) pairs.add('game_fish=true');
    if (sortBy != null) pairs.add('sort_by=$sortBy');
    if (order != null) pairs.add('order=$order');
    if (limit != null) pairs.add('limit=${limit.toString()}');
    if (page != null) pairs.add('page=${page.toString()}');
    
    return Uri.parse('$baseUri${pairs.isNotEmpty ? '?' : ''}${pairs.join('&')}');
  }

  Future<List<FishData>> getRecentSurveys({
    List<String>? species,
    List<String>? county,
    List<String>? lake,
    String? minYear,
    String? maxYear,
    bool gameFishOnly = false,
    int? limit,
    int? page,
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
      limit: limit,
      page: page,
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
    int? limit,
    int? page,
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
      limit: limit,
      page: page,
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
    int? limit,
    int? page,
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
      limit: limit,
      page: page,
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

  Future<Map<String, dynamic>> getSpeciesStats(String speciesId) async {
    final response = await http.get(Uri.parse('$baseUrl/species/id/$speciesId'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load species stats');
    }
  }

  Future<Map<String, dynamic>> getSpeciesById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/species/id/$id'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getCountyStats(String countyId) async {
    final response = await http.get(Uri.parse('$baseUrl/counties/id/$countyId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load county stats');
    }
  }

  Future<List<FishData>> getSurveysByIds(List<String> surveyIds) async {
    final queryParams = {'survey_ids': surveyIds.join(',')};
    final response = await http.get(Uri.parse('$baseUrl/data').replace(queryParameters: queryParams));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FishData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surveys');
    }
  }
} 