import 'package:flutter/material.dart';
import 'package:front/screen/friend_screen/friend_main.dart';
import 'package:front/screen/gathering_screen/gathering_main.dart';
import 'package:front/screen/myPage_screen/myPage_main.dart';
import 'package:front/screen/randomChating_screen/random_chat_main.dart';
import 'package:front/screen/wazzup_screen/wazzup_main.dart';

class TabInfo{
  final IconData icon;
  final String label;
  final Widget screen;

  const TabInfo({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

final TABS =[
  TabInfo(
    icon: Icons.location_searching_outlined,
    label: '모임소식',
    screen: GatheringMain(),
  ),
  TabInfo(
    icon: Icons.question_answer_outlined,
    label: '랜덤채팅',
    screen: RandomChatMain(),

  ),
  TabInfo(
    icon: Icons.home_max_outlined,
    label: 'WAZZUP',
    screen: WazzupMain(),

  ),
  TabInfo(
    icon: Icons.group_add_outlined,
    label: '친구',
    screen: FriendMain(),

  ),
  TabInfo(
    icon: Icons.person_outline_outlined,
    label: '마이',
    screen:MypageMain() ,

  ),
];