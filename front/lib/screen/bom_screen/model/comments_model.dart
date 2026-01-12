class Comments {
  final int? commentIdx;
  final int? parentIdx;
  final int? bbsIdx;
  final int? usersIdx;
  final String? content;
  final DateTime? createdAt;
  final String? nickName;

  Comments({
    this.commentIdx,
    this.parentIdx,
    this.bbsIdx,
    this.usersIdx,
    this.content,
    this.createdAt,
    this.nickName
  });

  factory Comments.fromJson(Map<String,dynamic> json){
    return Comments(
      commentIdx: json['commentsIdx'],
      parentIdx: json['parentIdx'] ,
      bbsIdx: json['bbsIdx'],
      usersIdx: json['usersIdx'],
      nickName: json['nickName'],
      content: json['content'],
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : null,
    );
  }

  // POST용: 서버로 보낼 때 필요한 필드만 Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'parentIdx': parentIdx, // 일반 댓글이면 null, 대댓글이면 부모 ID
      'bbsIdx': bbsIdx,       // 필수: 어떤 게시글인지
      'content': content,     // 필수: 댓글 내용
      // commentIdx, usersIdx, createdAt은 서버에서 처리하므로 제외하거나 null로 전송
    };
  }
}