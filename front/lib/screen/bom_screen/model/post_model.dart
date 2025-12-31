import 'package:front/dto/bbs/post_list_dto.dart';

class Post {
  final int bbsIdx;
  final String author; // nickname을 author로 명칭 변경 (직관적)
  final int viewCount;
  final int likeCount;
  final bool isLiked;
  final int commentCount;
  final String displayDate; // 가공된 날짜 (예: 12/19)
  final List<String> imageUrls; // img_name이 있을 경우의 경로
  // final String? gneder;
  final String content;

  Post({
    required this.bbsIdx,
    required this.author,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.displayDate,
    // required this.gneder,
    required this.imageUrls,
    required this.content,
    required this.isLiked
  });


  Post copyWith({
    int? bbsIdx,
    String? author,
    int? viewCount,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    String? displayDate,
    List<String>? imageUrls,
    String? content,
  }) {
    return Post(
      bbsIdx: bbsIdx ?? this.bbsIdx,
      author: author ?? this.author,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount, // 이게 있어야 좋아요 숫자 변경 가능
      isLiked: isLiked ?? this.isLiked,       // 이게 있어야 하트 색 변경 가능
      commentCount: commentCount ?? this.commentCount,
      displayDate: displayDate ?? this.displayDate,
      imageUrls: imageUrls ?? this.imageUrls,
      content: content ?? this.content,
    );
  }



  //  DTO를 받아서 Model로 변환
  factory Post.fromListDto(PostListDto dto) {
    return Post(
      bbsIdx: dto.bbsIdx!,
      author: dto.nickname!,
      viewCount: dto.viewCount!,

      // 2. 라이크 카운트 (현재는 0, 나중에 서버에서 가공해서 줄 값)
      likeCount: dto.likeCount ?? 0,  
      isLiked: dto.isLiked,

      commentCount: dto.commentCount ?? 0,
      displayDate: _formatDate(dto.createdAt),
      imageUrls: dto.imgUrls ?? [],
      content: dto.content ?? "",
    );
  }




static String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';
  
  try {
    // 1. 서버 응답 뒤에 타임존 정보가 없다면 강제로 +09:00을 붙여서 파싱
    String formattedStr = dateStr;
    if (!dateStr.contains('+') && !dateStr.contains('Z')) {
      formattedStr = '${dateStr}+09:00'; 
    }

    DateTime postDate = DateTime.parse(formattedStr).toLocal();
    DateTime now = DateTime.now();
    
    // 2. 현재 시간과 게시글 시간의 차이 계산
    Duration diff = now.difference(postDate);

    // ⚠️ 중요: 서버/폰 시간 오차로 인해 음수(미래)가 나올 경우 "방금 전" 처리
    if (diff.isNegative || diff.inMinutes < 1) {
      return "방금 전";
    } 
    
    // 3. 정상적인 시간 차이 계산
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}분 전";
    } 
    if (diff.inHours < 24) {
      return "${diff.inHours}시간 전";
    }
    if (diff.inDays < 7) {
      return "${diff.inDays}일 전";
    } else {
      return "${postDate.month}/${postDate.day}";
    }
  } catch (e) {
    // 파싱 실패 시 예외 처리
    return dateStr.length >= 10
        ? dateStr.substring(5, 10).replaceAll('-', '/')
        : dateStr;
  }
}
}
