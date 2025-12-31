import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/theme/app_colors.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final int bbsIdx;

  const CommentBottomSheet({super.key, required this.bbsIdx});

  static void show(BuildContext context, int bbsIdx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(bbsIdx: bbsIdx),
    );
  }

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  // ★ 핑크와 정반대되는 아주 연하고 맑은 물빛 하늘색
  final Color softSkyBlue = const Color(0xFFEBF5FF); 
  final Color _textColor = const Color(0xFF212529);

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isComposing = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: softSkyBlue, // ★ 맑은 물빛 배경 적용
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // 1. 헤더 (배경이 연하므로 텍스트는 진하게)
              _buildHeader(context),

              // 2. 댓글 리스트 (PostCard 레이아웃 무한 반복)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 30),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(index);
                  },
                ),
              ),

              // 3. 하단 입력바
              _buildInputBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("댓글", style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Text("12", style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _textColor, size: 28),
          ),
        ],
      ),
    );
  }

  // ★ PostCard와 100% 동일한 위젯 구조 (Stack + Positioned -33)
  Widget _buildCommentCard(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 38, 21, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 기존 PostHeader 그대로 사용 (프로필 -33 튀어나오는 로직 포함됨)
          PostHeader(customName: "유저 $index", showMore: true),

          // 댓글 본체 카드
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.05), // 배경색에 맞춘 아주 연한 푸른 그림자
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5), // 헤더 영역 확보
                  Text(
                    "확실히 연한 하늘색 배경이 핑크색 메인 컬러랑 대비되어서 훨씬 세련되어 보이네요! 이게 정답인 듯 합니다.",
                    style: postContentStyle, // PostWriteScreen에서 쓰신 스타일 그대로
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("답글 달기", style: TextStyle(color: Color(0xFFADB5BD), fontSize: 12, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Icons.favorite_border, size: 16, color: Color(0xFFDEE2E6)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '댓글을 남겨주세요.',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: _isComposing ? () {} : null,
            child: Text(
              "등록",
              style: TextStyle(
                color: _isComposing ? Colors.blueAccent : Colors.grey[300],
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ],
      ),
    );
  }
}