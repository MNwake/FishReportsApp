import 'package:frontend/core/models/fish_survey.dart';

class PaginatedResponse {
  final List<FishSurvey> data;
  final int limit;
  final int page;
  final int? prevPage;
  final int? nextPage;
  final int total;

  const PaginatedResponse({
    required this.data,
    required this.limit,
    required this.page,
    this.prevPage,
    this.nextPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      data: (json['data'] as List)
          .map((item) => FishSurvey.fromJson(item as Map<String, dynamic>))
          .toList(),
      limit: json['limit'] as int? ?? 50,
      page: json['page'] as int? ?? 1,
      prevPage: json['prev_page'] as int?,
      nextPage: json['next_page'] as int?,
      total: json['total'] as int? ?? 0,
    );
  }
} 