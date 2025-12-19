// lib/data/dto/post_list_dto.dart

class PostListDto {
  final int? bbsIdx;        // 게시글 식별자
  final int? bbsTypeIdx;    // 게시판 타입 (자유, 운동 등)
  final int? usersIdx;      // 작성자 식별자
  final String? title;      // 제목
  final String? nickname;   // 작성자 닉네임 (보통 DB Join으로 가져옴)
  final int? viewCount;     // 조회수
  final String? createdAt;  // 작성일
  final String? imgName;    // 리스트에 보여줄 썸네일 이미지명
  final int? likeCount;     // 해당 게시글의 좋아요 총 개수 (Reaction 테이블 집계)
  final int? commentCount;
  final String? content;
  // final String? gender;


  PostListDto({
    this.bbsIdx,
    this.bbsTypeIdx,
    this.usersIdx,
    this.title,
    this.nickname,
    this.viewCount,
    this.createdAt,
    this.imgName,
    this.likeCount,
    this.commentCount,
    this.content,
    // this.gender,
  });

  // 서버의 snake_case 응답을 Dart의 camelCase 필드에 매핑
  factory PostListDto.fromJson(Map<String, dynamic> json) {
    return PostListDto(
      bbsIdx: json['bbsIdx'],
      bbsTypeIdx: json['bbsTypeIdx'],
      usersIdx: json['usersIdx'],
      title: json['title'],
      nickname: json['usersNickname'], // 서버 API에서 JOIN해서 준다고 가정
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
      imgName: json['imgName'],
      likeCount: json['likeCount'], // 서버 API에서 COUNT해서 준다고 가정
      commentCount: json['commentCount'],
      // gender: json['usersGender']
      content: json['content'],
    );
  }
}