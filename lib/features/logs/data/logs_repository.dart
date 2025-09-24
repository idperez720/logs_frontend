import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class LogCreateRequest {
  final String content; // required
  final String? title; // optional
  final String?
      status; // "DRAFT" | "PUBLISHED" | "ARCHIVED" (default PUBLISHED)
  final String? logType; // "TEXT" | "VOICE" | "IMAGE" | "MIXED" (default TEXT)
  final String? location; // optional
  final String? mood; // optional
  final List<String>? tagIds; // optional

  LogCreateRequest({
    required this.content,
    this.title,
    this.status,
    this.logType,
    this.location,
    this.mood,
    this.tagIds,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        if (title != null && title!.isNotEmpty) 'title': title,
        if (status != null) 'status': status,
        if (logType != null) 'log_type': logType,
        if (location != null && location!.isNotEmpty) 'location': location,
        if (mood != null && mood!.isNotEmpty) 'mood': mood,
        if (tagIds != null && tagIds!.isNotEmpty) 'tag_ids': tagIds,
      };
}

class LogsRepository {
  final Dio _dio = ApiClient.I.dio;

  Future<Map<String, dynamic>> createLog(LogCreateRequest req) async {
    final res = await _dio.post('/api/v1/logs/', data: req.toJson());
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> recent({int limit = 10}) async {
    final res = await _dio
        .get('/api/v1/logs/recent', queryParameters: {'limit': limit});
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data;
  }
}
