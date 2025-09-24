import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class TagItem {
  final String id;
  final String name;
  final String? color;
  TagItem({required this.id, required this.name, this.color});

  factory TagItem.fromJson(Map<String, dynamic> j) => TagItem(
        id: j['id'] as String,
        name: j['name'] as String,
        color: j['color'] as String?,
      );
}

class TagsRepository {
  final Dio _dio = ApiClient.I.dio;

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

  Future<List<TagItem>> list({
    int page = 1,
    int size = 50,
    String? search,
    String? color,
    bool? hasLogs,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final qp = <String, dynamic>{
        'page': page,
        'size': size,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };
      if (search != null && search.isNotEmpty) qp['search'] = search;
      if (color != null && color.isNotEmpty) qp['color'] = color;
      if (hasLogs != null) qp['has_logs'] = hasLogs;

      final res = await _dio.get('/api/v1/tags/', queryParameters: qp);
      final map = res.data as Map<String, dynamic>;
      final tags = (map['tags'] as List).cast<Map<String, dynamic>>();
      return tags.map(TagItem.fromJson).toList();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  // NEW: quick create (name only)
  Future<TagItem> createTag(
      {required String name, String? color, String? description}) async {
    final body = {
      'name': name,
      if (color != null) 'color': color,
      if (description != null) 'description': description
    };
    try {
      final res = await _dio.post('/api/v1/tags/', data: body);
      return TagItem.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<void> deleteTag(String tagId) async {
    try {
      await _dio.delete('/api/v1/tags/$tagId');
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<TagItem> getTag(String tagId) async {
    try {
      final res = await _dio.get('/api/v1/tags/$tagId');
      return TagItem.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<TagItem> updateTag(
    String tagId, {
    String? name,
    String? color,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (color != null) body['color'] = color;
    if (description != null) body['description'] = description;

    try {
      final res = await _dio.put('/api/v1/tags/$tagId', data: body);
      return TagItem.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<List<TagItem>> popular({int limit = 10}) async {
    try {
      final res = await _dio
          .get('/api/v1/tags/popular', queryParameters: {'limit': limit});
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(TagItem.fromJson).toList();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<List<TagItem>> unused() async {
    try {
      final res = await _dio.get('/api/v1/tags/unused');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(TagItem.fromJson).toList();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> statsAll() async {
    try {
      final res = await _dio.get('/api/v1/tags/stats/all');
      return (res.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<Map<String, dynamic>> statsForTag(String tagId) async {
    try {
      final res = await _dio.get('/api/v1/tags/$tagId/stats');
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<Map<String, dynamic>> cleanupUnused({int olderThanDays = 30}) async {
    try {
      final res = await _dio.delete(
        '/api/v1/tags/cleanup',
        queryParameters: {'older_than_days': olderThanDays},
      );
      return (res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFromDioError(e);
    }
  }

  Future<Map<String, dynamic>> search({
    String? query,
    String? color,
    bool? hasLogs,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int page = 1,
    int size = 10,
  }) async {
    final body = <String, dynamic>{};
    if (query != null && query.isNotEmpty) body['query'] = query;
    if (color != null && color.isNotEmpty) body['color'] = color;
    if (hasLogs != null) body['has_logs'] = hasLogs;
    if (createdAfter != null) {
      body['created_after'] = createdAfter.toIso8601String();
    }
    if (createdBefore != null) {
      body['created_before'] = createdBefore.toIso8601String();
    }

    try {
      final res = await _dio.post(
        '/api/v1/tags/search',
        queryParameters: {'page': page, 'size': size},
        data: body,
      );
      return (res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }
}
