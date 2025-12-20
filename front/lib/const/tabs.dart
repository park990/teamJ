import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/screen/friend_screen/friend_main.dart';
import 'package:front/screen/gathering_screen/gathering_main.dart';
import 'package:front/screen/myPage_screen/myPage_main.dart';
import 'package:front/screen/random_chat_screen/random_chat_main.dart';
import 'package:front/screen/bom_screen/bom_main.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    icon: LucideIcons.home,
    label: 'home',
    screen: GatheringMain(),
  ),
  TabInfo(
    icon: LucideIcons.messageCircle,
    label: 'wChat',
    screen: RandomChatMain(),

  ),
  TabInfo(
    icon: LucideIcons.flower,
    label: 'Bom',
    screen: BomMain(),

  ),
  TabInfo(
    icon: LucideIcons.users,
    label: 'friends',
    screen: FriendMain(),

  ),
  TabInfo(
    icon: LucideIcons.userCircle2,
    label: 'profile',
    screen:MypageMain() ,

  ),
];