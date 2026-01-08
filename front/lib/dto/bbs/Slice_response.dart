class SliceResponse<T> {
  final List<T> content;
  final bool isLast;

  SliceResponse({
    required this.content,
    required this.isLast,
  });


  // JSON 데이터를 받아서 SliceResponse 객체로 변환해주는 마법의 생성자
  factory SliceResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic) fromJsonT, // 각 아이템을 변환할 함수
  ) {
    return SliceResponse<T>(
      content: (json['content'] as List).map(fromJsonT).toList(),
      isLast: json['last'] ?? true,
    );
  }
}
