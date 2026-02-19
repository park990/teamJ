import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/nav_bar_screen/bottom_nav_bar.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_state.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';

/// 전역 매칭 상태 오버레이
/// - 매칭 중일 때 앱 상단에 배너 표시
/// - 클릭 시 매칭 화면으로 이동
class MatchingStatusOverlay extends ConsumerStatefulWidget {
  const MatchingStatusOverlay({super.key});

  @override
  ConsumerState<MatchingStatusOverlay> createState() =>
      _MatchingStatusOverlayState();
}

class _MatchingStatusOverlayState extends ConsumerState<MatchingStatusOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1), // 위에서 시작
          end: Offset.zero, // 현재 위치로
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 매칭 상태 감시
    final matchState = ref.watch(randomMatchControllerProvider).state;
    final isMatching = matchState.status == RandomChatStatus.matching;

    // 애니메이션 제어
    if (isMatching) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    // 매칭 중이 아니면 아무것도 표시 안 함
    if (!isMatching) {
      return const SizedBox.shrink();
    }

    // ✅ 상단 배너 표시
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // 상태바 아래
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () {
              debugPrint('[MatchingStatusOverlay] 📍 배너 클릭 → 매칭 탭으로 전환');
              // ✅ Navigator.push 대신 탭 인덱스 변경 (탭바 유지)
              // Tab 1 = RandomChatMain (wChat)
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 회전하는 로딩 아이콘
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 매칭 중 텍스트
                  const Expanded(
                    child: Text(
                      '매칭 중... 탭하여 확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 탭 아이콘 (클릭 가능 힌트)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
