import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class SpinningFlower extends StatefulWidget {
  final RefreshStatus? mode;
  const SpinningFlower({super.key, this.mode});

  @override
  State<SpinningFlower> createState() => _SpinningFlowerState();
}

class _SpinningFlowerState extends State<SpinningFlower> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 2초 동안 한 바퀴 돌도록 설정
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didUpdateWidget(SpinningFlower oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 새로고침 상태(refreshing)일 때만 애니메이션 무한 반복
    if (widget.mode == RefreshStatus.refreshing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        LucideIcons.flower,// 꽃 모양 아이콘
        color: wazzupButton, // 꽃 색상
        size: 40,
      ),
    );
  }
}