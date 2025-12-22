import 'package:front/dto/bbs/post_list_dto.dart';

class Post {
  final int id;
  final String title;
  final String author; // nickname을 author로 명칭 변경 (직관적)
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String displayDate; // 가공된 날짜 (예: 12/19)
  final String? imageUrl; // img_name이 있을 경우의 경로
  // final String? gneder;
  final String content;

  Post({
    required this.id,
    required this.title,
    required this.author,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.displayDate,
    // required this.gneder,
    this.imageUrl,
    required this.content,
  });

  //  DTO를 받아서 Model로 변환
  factory Post.fromListDto(PostListDto dto) {
    return Post(
      id: dto.bbsIdx ?? 0,
      title: dto.title ?? '제목 없음',
      author: dto.nickname ?? '익명', // SocialUserDto에서 온 닉네임 사용
      viewCount: dto.viewCount ?? 0,
      likeCount: dto.likeCount ?? 0,
      commentCount: dto.commentCount ?? 0,
      displayDate: _formatDate(dto.createdAt),
      imageUrl: dto.imgName,
      // gneder: dto.gender,
      content: dto.content ?? "내용없음",
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';

    try {
      // 1. 서버 시간을 DateTime 객체로 변환 (UTC인 경우 .toLocal() 필수)
      DateTime postDate = DateTime.parse(dateStr).toLocal();
      DateTime now = DateTime.now();

      // 2. 오늘인지 확인 (연, 월, 일이 모두 같은지)
      bool isToday =
          postDate.year == now.year &&
          postDate.month == now.month &&
          postDate.day == now.day;

      if (isToday) {
        // 오늘이면 시:분 표시 (예: 14:30)
        String hour = postDate.hour.toString().padLeft(2, '0');
        String minute = postDate.minute.toString().padLeft(2,'0');
        return "$hour:$minute";
      } else {
        // 오늘이 아니면 월/일 표시 (예: 12/18)
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
