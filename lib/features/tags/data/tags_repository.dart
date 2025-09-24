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

  Future<List<TagItem>> list({int page = 1, int size = 50}) async {
    try {
      final res = await _dio
          .get('/api/v1/tags/', queryParameters: {'page': page, 'size': size});
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
}
