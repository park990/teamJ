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
      isScrollControlled: true, // 전체 높이 제어를 위해 필수
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(bbsIdx: bbsIdx),
    );
  }

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isComposing = false;

  final Color softSkyBlue = const Color(0xFFEBF5FF);

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
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // 키보드가 올라오면 시트를 최대 크기로 확장시킴
    if (keyboardHeight > 0) {
      _sheetController.animateTo(
        0.95, // 거의 전체 화면
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.7, // 처음 높이 0.7
      minChildSize: 0.4,     // 이 밑으로 내리면 닫히기 시작
      maxChildSize: 0.95,    // 최대 높이
      snap: true,            // ★ 스냅 기능 활성화
      snapSizes: const [0.7], // ★ 0.7 지점에 자석처럼 딱 걸리게 설정
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: softSkyBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              _buildHandle(),

              // 1. 헤더 (고정)
              _buildHeader(context),

              // 2. 댓글 리스트
              Expanded(
                child: ListView.builder(
                  // 반드시 DraggableScrollableSheet에서 제공하는 scrollController를 써야 함
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: 20,
                  itemBuilder: (context, index) => _buildCommentCard(index),
                ),
              ),

              // 3. 하단 입력바
              _buildInputBar(context),
              
              // 키보드 높이만큼 공간 확보
              SizedBox(height: keyboardHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("댓글", style: wazzupBarFont),
    
      ],
    );
  }

  Widget _buildCommentCard(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 38, 21, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 헤더는 만들어진 위젯에 넣음
          PostHeader(customName: "유저 $index", showMore: true),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Text("내리면 0.7로 걸리고, 더 내리면 닫힙니다.", style: postContentStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              decoration: const InputDecoration(hintText: '댓글을 남겨주세요.', border: InputBorder.none),
            ),
          ),
          TextButton(
            onPressed: _isComposing ? () {} : null,
            child: const Text("등록", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}