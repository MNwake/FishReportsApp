import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/core/models/paginated_response.dart';
import 'package:frontend/core/models/county.dart';
import 'package:frontend/core/models/fish_survey.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));

  Future<PaginatedResponse> getFishData({
    String? species,
    String? minYear,
    List<String>? counties,
    String? sortBy,
    String? order,
    int limit = 50,
    int page = 1,
  }) async {
    try {

      final response = await _dio.get('/data', queryParameters: {
        if (species != null) 'species': species,
        if (minYear != null) 'minYear': minYear,
        if (counties != null && counties.isNotEmpty) 'county': counties.join(','),
        if (sortBy != null) 'sort_by': sortBy,
        if (order != null) 'order': order,
        'limit': limit,
        'page': page,
      });

      return PaginatedResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch fish data: $e');
    }
  }

  Future<GraphData> getFishGraphData({
    required String dow,
    required String species,
    required String date,
  }) async {
    try {
      final response = await _dio.get('/graph', queryParameters: {
        'dow': dow,
        'species': species,
        'date': date,
      });
      return GraphData.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch fish graph data: $e');
    }
  }

  Future<List<County>> getCounties() async {
    try {
      final response = await _dio.get('/counties');
      final List<dynamic> data = response.data['data'] as List;
      return data
          .map((county) => County.fromJson(county as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
    } catch (e) {
      throw Exception('Failed to fetch counties: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSpecies() async {
    try {
      final response = await _dio.get('/species');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch species: $e');
    }
  }

  Future<List<FishSurvey>> getFishSurveys({
    String? sortBy,
    String? order,
    int? limit,
    String? species,
    List<String>? counties,
    int? page,
  }) async {
    try {
      final response = await _dio.get('/data', queryParameters: {
        if (sortBy != null) 'sort_by': sortBy,
        if (order != null) 'order': order,
        if (limit != null) 'limit': limit,
        if (species != null) 'species': species,
        if (counties != null) 'counties': counties.join(','),
        if (page != null) 'page': page,
      });
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => FishSurvey.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch fish surveys: $e');
    }
  }
} 