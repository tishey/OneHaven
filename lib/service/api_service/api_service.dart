import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService(String baseUrl)
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    // Add interceptors for logging
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Future<List<dynamic>> fetchMembers() async {
    try {
      final response = await dio.get('/members');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to server. Please try again.');
      }
      throw Exception('Failed to fetch members: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch members from server');
    }
  }

  Future<Map<String, dynamic>> patchMember(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch('/members/$id', data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to update member: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update member');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed');
    }
  }
}
