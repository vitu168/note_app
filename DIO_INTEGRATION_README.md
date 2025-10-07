# Dio HTTP Client Integration

This document explains how to use Dio for API communication in the Flutter note app.

## Installation

Dio has been added to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
```

Run `flutter pub get` to install the package.

## Architecture

### ApiService Class
- **Location**: `lib/core/services/api_service.dart`
- **Purpose**: Centralized HTTP client with Dio
- **Features**:
  - Singleton pattern for consistent API calls
  - Automatic error handling and logging
  - Configurable timeouts and headers
  - Support for all HTTP methods (GET, POST, PUT, DELETE)
  - File upload/download capabilities

### ApiExamples Class
- **Purpose**: Example implementations showing how to use ApiService
- **Features**: Ready-to-use methods for common API operations

## Basic Usage

### Initialize the Service
```dart
final apiService = ApiService();
```

### GET Request
```dart
try {
  final data = await apiService.get('/posts');
  print('Posts: $data');
} catch (e) {
  print('Error: $e');
}
```

### POST Request
```dart
try {
  final newPost = await apiService.post('/posts', data: {
    'title': 'My Title',
    'body': 'My content',
    'userId': 1,
  });
  print('Created post: $newPost');
} catch (e) {
  print('Error: $e');
}
```

### PUT Request
```dart
try {
  final updatedPost = await apiService.put('/posts/1', data: {
    'title': 'Updated Title',
    'body': 'Updated content',
  });
  print('Updated post: $updatedPost');
} catch (e) {
  print('Error: $e');
}
```

### DELETE Request
```dart
try {
  await apiService.delete('/posts/1');
  print('Post deleted successfully');
} catch (e) {
  print('Error: $e');
}
```

## Advanced Features

### Authentication
```dart
// Set auth token
apiService.setAuthToken('your-jwt-token');

// Remove auth token
apiService.removeAuthToken();
```

### Custom Headers
```dart
// Add custom header
apiService.addHeader('X-API-Key', 'your-api-key');

// Remove header
apiService.removeHeader('X-API-Key');
```

### File Upload
```dart
try {
  final response = await apiService.uploadFile(
    '/upload',
    '/path/to/file.jpg',
    fieldName: 'image'
  );
  print('Upload successful: $response');
} catch (e) {
  print('Upload failed: $e');
}
```

### File Download
```dart
try {
  await apiService.downloadFile(
    'https://example.com/file.pdf',
    '/path/to/save/file.pdf',
    onReceiveProgress: (received, total) {
      if (total != -1) {
        print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
      }
    }
  );
  print('Download completed');
} catch (e) {
  print('Download failed: $e');
}
```

### Query Parameters
```dart
try {
  final posts = await apiService.get('/posts', queryParameters: {
    'userId': 1,
    'limit': 10,
  });
  print('Filtered posts: $posts');
} catch (e) {
  print('Error: $e');
}
```

## Error Handling

The ApiService includes comprehensive error handling:

```dart
try {
  final data = await apiService.get('/posts');
  // Handle success
} catch (e) {
  if (e.toString().contains('Connection timeout')) {
    // Handle timeout
  } else if (e.toString().contains('Unauthorized')) {
    // Handle auth error
  } else {
    // Handle other errors
  }
}
```

## Integration with UI Components

The API service works seamlessly with the app's UI components:

```dart
// Using with DynamicFriendlyDialog
try {
  final data = await apiService.get('/posts');
  DynamicFriendlyDialog.show(
    context: context,
    type: DialogType.success,
    title: 'Success',
    message: 'Data loaded successfully',
  );
} catch (e) {
  DynamicFriendlyDialog.show(
    context: context,
    type: DialogType.error,
    title: 'Error',
    message: 'Failed to load data: $e',
  );
}
```

## Configuration

### Base URL
```dart
// Change base URL
apiService.setBaseUrl('https://your-api.com/api/v1');
```

### Timeouts
Configure timeouts in the ApiService constructor:
```dart
_dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));
```

## Testing

Use the `ApiExamplePage` to test API functionality:
- Navigate to the API examples page
- Test GET, POST, PUT, DELETE operations
- View real-time responses and error handling

## Best Practices

1. **Always handle errors**: Wrap API calls in try-catch blocks
2. **Use loading states**: Show loading indicators during API calls
3. **Validate responses**: Check response data before using it
4. **Authentication**: Set auth tokens before making authenticated requests
5. **Logging**: Use the built-in logging for debugging
6. **Timeouts**: Configure appropriate timeouts for your use case

## Example Integration

Here's how to integrate Dio with your note app:

```dart
class NoteService {
  final ApiService _apiService = ApiService();

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await _apiService.get('/notes');
      return (response as List).map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<Note> createNote(String title, String content) async {
    try {
      final response = await _apiService.post('/notes', data: {
        'title': title,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return Note.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }
}
```

This setup provides a robust, scalable API layer for your Flutter note app with comprehensive error handling, logging, and integration with your existing UI components.