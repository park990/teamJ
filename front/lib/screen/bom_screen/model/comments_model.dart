class Comments {
  final int? commentIdx;
  final int? parentIdx;
  final int? bbsIdx;
  final int? usersIdx;
  final String? content;
  final DateTime? createdAt;

  Comments({
    this.commentIdx,
    this.parentIdx,
    this.bbsIdx,
    this.usersIdx,
    this.content,
    this.createdAt
  });

  factory Comments.fromJson(Map<String,dynamic> json){
    return Comments(
      commentIdx: json['commentsIdx'],
      parentIdx: json['parentIdx'],
      bbsIdx: json['bbsIdx'],
      usersIdx: json['usersIdx'],
      content: json['content'],
      createdAt: json['createdAt'],
    );
  }
}