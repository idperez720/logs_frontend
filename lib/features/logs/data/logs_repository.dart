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

class LogUpdateRequest {
  final String? title;
  final String? content;
  final String? status; // DRAFT | PUBLISHED | ARCHIVED
  final String? logType; // TEXT | VOICE | IMAGE | MIXED
  final String? location;
  final String? mood;
  LogUpdateRequest({
    this.title,
    this.content,
    this.status,
    this.logType,
    this.location,
    this.mood,
  });
  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (status != null) 'status': status,
        if (logType != null) 'log_type': logType,
        if (location != null) 'location': location,
        if (mood != null) 'mood': mood,
      };
}

class LogSearchRequestBody {
  final String? query;
  final String? status; // DRAFT | PUBLISHED | ARCHIVED
  final String? logType; // TEXT | VOICE | IMAGE | MIXED
  final List<String>? tagIds;
  final String? location;
  final String? mood;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? wordCountMin;
  final int? wordCountMax;

  LogSearchRequestBody({
    this.query,
    this.status,
    this.logType,
    this.tagIds,
    this.location,
    this.mood,
    this.createdAfter,
    this.createdBefore,
    this.wordCountMin,
    this.wordCountMax,
  });

  Map<String, dynamic> toJson() => {
        if (query != null && query!.isNotEmpty) 'query': query,
        if (status != null) 'status': status,
        if (logType != null) 'log_type': logType,
        if (tagIds != null && tagIds!.isNotEmpty) 'tag_ids': tagIds,
        if (location != null && location!.isNotEmpty) 'location': location,
        if (mood != null && mood!.isNotEmpty) 'mood': mood,
        if (createdAfter != null)
          'created_after': createdAfter!.toIso8601String(),
        if (createdBefore != null)
          'created_before': createdBefore!.toIso8601String(),
        if (wordCountMin != null) 'word_count_min': wordCountMin,
        if (wordCountMax != null) 'word_count_max': wordCountMax,
      };
}

class LogsRepository {
  final Dio _dio = ApiClient.I.dio;

  Future<Map<String, dynamic>> createLog(LogCreateRequest req) async {
    try {
      final res = await _dio.post('/api/v1/logs/', data: req.toJson());
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> recent({int limit = 10}) async {
    try {
      final res = await _dio
          .get('/api/v1/logs/recent', queryParameters: {'limit': limit});
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data;
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// GET /api/v1/logs/
  /// Returns paginated logs with optional filters and sorting.
  Future<Map<String, dynamic>> list({
    int page = 1,
    int size = 10,
    String? search,
    String? statusFilter, // DRAFT|PUBLISHED|ARCHIVED
    String? logType, // TEXT|VOICE|IMAGE|MIXED
    String? location,
    String? mood,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final qp = <String, dynamic>{
        'page': page,
        'size': size,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };
      if (search != null && search.isNotEmpty) qp['search'] = search;
      if (statusFilter != null) qp['status_filter'] = statusFilter;
      if (logType != null) qp['log_type'] = logType;
      if (location != null && location.isNotEmpty) qp['location'] = location;
      if (mood != null && mood.isNotEmpty) qp['mood'] = mood;

      final res = await _dio.get('/api/v1/logs/', queryParameters: qp);
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// GET /api/v1/logs/drafts
  Future<List<Map<String, dynamic>>> drafts() async {
    try {
      final res = await _dio.get('/api/v1/logs/drafts');
      return (res.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// GET /api/v1/logs/{log_id}
  Future<Map<String, dynamic>> getById(String logId) async {
    try {
      final res = await _dio.get('/api/v1/logs/$logId');
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// PUT /api/v1/logs/{log_id}
  Future<Map<String, dynamic>> update(
      String logId, LogUpdateRequest req) async {
    try {
      final res = await _dio.put('/api/v1/logs/$logId', data: req.toJson());
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// DELETE /api/v1/logs/{log_id}
  Future<void> delete(String logId) async {
    try {
      await _dio.delete('/api/v1/logs/$logId');
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// PUT /api/v1/logs/{log_id}/tags
  /// The API expects LogTagsUpdateRequest; we send the single id in `log_ids`.
  Future<Map<String, dynamic>> updateTags(
      String logId, List<String> tagIds) async {
    try {
      final body = {
        'tag_ids': tagIds,
        'log_ids': [logId],
      };
      final res = await _dio.put('/api/v1/logs/$logId/tags', data: body);
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// POST /api/v1/logs/{log_id}/archive
  Future<Map<String, dynamic>> archive(String logId) async {
    try {
      final res = await _dio.post('/api/v1/logs/$logId/archive');
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// POST /api/v1/logs/{log_id}/unarchive
  Future<Map<String, dynamic>> unarchive(String logId) async {
    try {
      final res = await _dio.post('/api/v1/logs/$logId/unarchive');
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// POST /api/v1/logs/search
  Future<Map<String, dynamic>> search({
    required LogSearchRequestBody body,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final res = await _dio.post(
        '/api/v1/logs/search',
        queryParameters: {'page': page, 'size': size},
        data: body.toJson(),
      );
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// GET /api/v1/logs/stats/overview
  Future<Map<String, dynamic>> statsOverview() async {
    try {
      final res = await _dio.get('/api/v1/logs/stats/overview');
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// POST /api/v1/logs/bulk-update
  Future<Map<String, dynamic>> bulkUpdate({
    required List<String> logIds,
    String? status,
    List<String>? tagIdsToAdd,
    List<String>? tagIdsToRemove,
  }) async {
    try {
      final body = {
        'log_ids': logIds,
        if (status != null) 'status': status,
        if (tagIdsToAdd != null) 'tag_ids_to_add': tagIdsToAdd,
        if (tagIdsToRemove != null) 'tag_ids_to_remove': tagIdsToRemove,
      };
      final res = await _dio.post('/api/v1/logs/bulk-update', data: body);
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  /// DELETE /api/v1/logs/cleanup-drafts
  Future<Map<String, dynamic>> cleanupDrafts({int olderThanDays = 30}) async {
    try {
      final res = await _dio.delete(
        '/api/v1/logs/cleanup-drafts',
        queryParameters: {'older_than_days': olderThanDays},
      );
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  String _messageFromDioError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      if (data is Map && data['detail'] is List && data['detail'].isNotEmpty) {
        final first = data['detail'].first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
      if (e.message != null && e.message!.isNotEmpty) return e.message!;
    } catch (_) {}
    return 'Request failed';
  }
}
