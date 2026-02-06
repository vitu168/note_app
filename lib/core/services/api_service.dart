import 'package:dio/dio.dart';
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Handle common errors
          switch (error.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              throw Exception(
                  'Connection timeout. Please check your internet connection.');
            case DioExceptionType.badResponse:
              _handleBadResponse(error);
              break;
            case DioExceptionType.cancel:
              throw Exception('Request cancelled');
            default:
              throw Exception('Something went wrong. Please try again.');
          }
          handler.next(error);
        },
      ),
    ]);
  }

  void _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case 400:
        throw Exception(
            'Bad request: ${responseData?['message'] ?? 'Invalid request'}');
      case 401:
        throw Exception('Unauthorized: Please check your credentials');
      case 403:
        throw Exception(
            'Forbidden: You don\'t have permission to access this resource');
      case 404:
        throw Exception('Not found: The requested resource was not found');
      case 422:
        throw Exception(
            'Validation error: ${responseData?['message'] ?? 'Invalid data'}');
      case 500:
        throw Exception('Server error: Please try again later');
      default:
        throw Exception(
            'HTTP $statusCode error: ${responseData?['message'] ?? 'Unknown error'}');
    }
  }

  // Generic GET request
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
      await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(endpoint,
          data: data, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(endpoint,
          data: data, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.delete(endpoint, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Upload file
  Future<dynamic> uploadFile(String endpoint, String filePath,
      {String fieldName = 'file'}) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Download file
  Future<void> downloadFile(String url, String savePath,
      {ProgressCallback? onReceiveProgress}) async {
    try {
      await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
    } catch (e) {
      rethrow;
    }
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Update base URL
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Add custom headers
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  // Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }
}

/// Example usage class demonstrating how to use the ApiService
class ApiExamples {
  final ApiService _apiService = ApiService();

  // Example: Fetch posts from JSONPlaceholder API
  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await _apiService.get('/posts');
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Example: Create a new post
  Future<dynamic> createPost(String title, String body, int userId) async {
    try {
      final data = {
        'title': title,
        'body': body,
        'userId': userId,
      };

      final response = await _apiService.post('/posts', data: data);
      return response;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Example: Update a post
  Future<dynamic> updatePost(int postId, String title, String body) async {
    try {
      final data = {
        'title': title,
        'body': body,
      };

      final response = await _apiService.put('/posts/$postId', data: data);
      return response;
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Example: Delete a post
  Future<void> deletePost(int postId) async {
    try {
      await _apiService.delete('/posts/$postId');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Example: Fetch posts with query parameters
  Future<List<dynamic>> fetchPostsByUser(int userId) async {
    try {
      final response =
          await _apiService.get('/posts', queryParameters: {'userId': userId});
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  // Example: Set authentication token
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  // Example: Upload a file
  Future<dynamic> uploadImage(String filePath) async {
    try {
      final response =
          await _apiService.uploadFile('/upload', filePath, fieldName: 'image');
      return response;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
