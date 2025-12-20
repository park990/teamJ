import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BomMain extends ConsumerWidget {
  const BomMain({super.key});

  @override
  Widget build(BuildContext context,ref) {
          bool _isLoggedIn = ref.watch(authControllerProvider).isLoggedIn;
    // ⚠️ 레이아웃 테스트용 더미 데이터
    final List<Post> dummyPosts = [
      Post(id: 1, title: 'WAZZUP 앱 디자인 대격변 진행sadf 중asdfsdfsdfsdfㄴㅇㄹㄴㅇㄹㄴㅇㄹㄴㅇㄹㄹ123123132123123sdfasdf!',content: "아아아아마ㅓㅇ너ㅏ마어ㅣㅏㅓ민러ㅏㅣㄹㄴㅁ어ㅏㅁㄴ라ㅓㅣㅁㄴㅇ라ㅣㅓㅁㄴㅇ러ㅏㅣ;", author: '하두셋넷다여읽엷아열하두셋', viewCount: 999, likeCount: 822, commentCount: 525, displayDate: '14:30'),
      Post(id: 2, title: '카드의 크기를 줄이고 간격을 좁혔습니다.', author: '디자이너123', viewCount: 0,content:'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ', likeCount: 12, commentCount: 2, displayDate: '11:05'),
      Post(id: 3, title: '이제 긴 제목도 레이아웃이 깨지지 않고 아주 깔끔하게 두 줄로 처리됩니다.',content:'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ', author: '코딩왕', viewCount: 2123, likeCount: 30, commentCount: 128, displayDate: '12/18'),
      Post(id: 4, title: '리스트가 촘촘해지니 훨씬 보기 좋네요.', author: '유저1', viewCount: 50, likeCount: 3, commentCount: 0, displayDate: '10:20',content: 'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ',),
      Post(id: 3, title: '이제 긴 제목도 레이아웃이 깨지지 않고 아주 깔끔하게 두 줄로 처리됩니다.',content:'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ', author: '코딩왕', viewCount: 2123, likeCount: 30, commentCount: 128, displayDate: '12/18'),
      Post(id: 4, title: '리스트가 촘촘해지니 훨씬 보기 좋네요.', author: '유저1', viewCount: 50,content:'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ', likeCount: 3, commentCount: 0, displayDate: '10:20'),
      Post(id: 3, title: '이제 긴 제목도 레이아웃이 깨지지 않고 아주 깔끔하게 두 줄로 처리됩니다.', author: '코딩왕', viewCount: 2123, likeCount: 30, commentCount: 128, displayDate: '12/18',content: 'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ',),
      Post(id: 4, title: '리스트가 촘촘해지니 훨씬 보기 좋네요.', author: '유저1', viewCount: 50, likeCount: 3, commentCount: 0, displayDate: '10:20',content: 'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ',),
      Post(id: 5, title: '닉네임이 길어지면 어떻게 될까요? 테스트 중입니다.', author: '오이오이오오근데만약닉네임이길어지면어떻게될라나', viewCount: 999, likeCount: 822, commentCount: 525, displayDate: '14:30',content: 'ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㄹㅇ',),
    ];

    return Scaffold(
      backgroundColor: wazzupBackGround, // 배경
      
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4), 
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          return _PostCard(post: dummyPosts[index]);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
        print('글쓰기 클릭');
          if(!_isLoggedIn){
            WazzupToast.showError('로그인이 필요합니다');
          }
          
        },
      backgroundColor: wazzupButton.withValues(alpha: 0.75),
      elevation: 2,
      
      child: Icon(Icons.add,color: Colors.white,)
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드들 사이 간격
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1), // 카드 테두리
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // 여기서 클릭하면 상세 글 화면으로 넘어가야함
        onTap: () {print('${post.id}클릭');},
        child: Padding(
          // 카드안에 든 내용물과 카드의 패딩
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // --- 상단 영역: 제목 + 이미지 플레이스홀더 ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(  
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.displayDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFADB5BD), // 연한 쿨그레이
                          ),
                        ),
                        Text(post.title,
                          style: wazzupFont.copyWith(fontSize: 15,fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                          SizedBox(height: 1,),
                          Text(post.content.length > 8 
                          ? '${post.content.substring(0, 8)} ...' 
                          : post.content,
                          style: wazzupFont.copyWith(fontSize: 10,color: Color(0xFF495057),),
                          maxLines: 1,overflow: TextOverflow.ellipsis,)
                       ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- 🖼️ 업그레이드된 이미지 플레이스홀더 ---
                  Padding(
                    // 사진만 살짝 아래로
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA), 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                        
                      ),
                      child: const Icon(
                        Icons.image_outlined, 
                        color: Color(0xFFDEE2E6), 
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // --- 하단 영역: [작성자 · 시간] | [하트 댓글 조회] ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. 왼쪽: 작성자 정보 (Slate Grey 적용)
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.author,
                            style: const TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w500, 
                              color: Color(0xFF495057), // 세련된 진회색
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. 오른쪽: 통계 (구분선 제거 및 간격 최적화)
                  Row(
                    children: [
                      _buildSeparator(),
                      _buildStat(LucideIcons.heart, post.likeCount, Colors.redAccent),
                      const SizedBox(width: 10),
                      _buildStat(LucideIcons.messageCircle, post.commentCount, Colors.blueAccent),
                      const SizedBox(width: 10),
                      _buildStat(LucideIcons.trendingUp, post.viewCount, Colors.yellow[900]!),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 통계 아이콘 위젯
  Widget _buildStat(IconData icon, int count, Color color) {
    final bool isZero = count == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          size: 14, 
          color: isZero ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.5)
        ),
        const SizedBox(width: 4),
        Text(
          count > 999 ? '999+' : '$count',
          style: TextStyle(
            fontSize: 11,
            color: isZero ? const Color(0xFFDEE2E6) : const Color(0xFF868E96),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

    Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: TextStyle(fontSize: 10, color: Colors.grey[50])),
    );
  }

}