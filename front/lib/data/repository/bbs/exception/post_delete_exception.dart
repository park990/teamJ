
// 1. 게시글이 삭제되었을 때 던질 전용 예외
class PostDeletedException implements Exception {
  final String message;
  
  // 생성자: 에러 메시지를 받아서 저장함
  PostDeletedException(this.message);

  @override
  String toString() {
    // 에러를 출력할 때 보여줄 문구
    return message; 
  }
}
