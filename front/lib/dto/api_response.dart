
class ApiResponse<T> {
  final String result;
  final String message;
  final T? data;

  ApiResponse({
    required this.result,
    required this.message,
    this.data,
  });

  // JSON -> 객체 변환 (T를 파싱하는 로직은 호출하는 곳에서 처리)
  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic json)? fromJsonT) {
    return ApiResponse<T>(
      result: json['result'],
      message: json['message'],
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => result == "success";
}