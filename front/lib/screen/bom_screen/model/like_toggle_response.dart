// like_toggle_model.dart (또는 post_model.dart 하단)
class LikeToggleResponse {
  final bool isLiked;
  final int likeCount;

  LikeToggleResponse({
    required this.isLiked,
    required this.likeCount,
  });

  // JSON 파싱 팩토리
  factory LikeToggleResponse.fromJson(Map<String, dynamic> json) {
    return LikeToggleResponse(
      isLiked: json['liked'] as bool,
      likeCount: json['likeCount'] as int,
    );
  }
}