# API & Error Handling Rules

## Frontend (Flutter)

### ApiClient Usage
- ✅ **ALWAYS use `ApiClient`** from `api_client.dart`
- ✅ Uses `http` package (NOT Dio)
- ✅ Auto-handles 401/403 with token refresh via `_refreshAccessToken()`
- ✅ Supports: `get()`, `post()`, `postMultipart()`

### Error Handling Pattern
```dart
final response = await apiClient.get('/api/endpoint');
if (response.statusCode != 200) {
  print('Error: ${response.statusCode}');
  return defaultValue; // or throw exception
}
final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
```

### Critical Rules
- ❌ **NO Dio migration** - manual logging is sufficient
- ❌ **NO direct http.get/post** - always use ApiClient
- ✅ Manual error logging OK (no interceptor needed)

## Backend (Spring Boot)

### GlobalExceptionHandler
- Centralized error handling via `@RestControllerAdvice`
- Handles: `BbsException`, `IllegalArgumentException`, generic `Exception`
- Returns: `ApiResponse<T>` with result/message/data

### Exception Pattern
```java
throw new BbsException(CommentsErrorCode.POST_DELETED);
```

### Response Format
```json
{
  "result": "fail",
  "message": "삭제된 게시글입니다.",
  "data": null
}
```

## Error Layer Separation

| Layer | Responsibility | Handler |
|-------|----------------|---------|
| Network | Connection, Timeout, DNS | ApiClient (401/403 retry) |
| Application | Business Logic | GlobalExceptionHandler |
