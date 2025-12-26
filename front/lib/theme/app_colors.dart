import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//#df8eb6
//#a7c3f3
//#FFF5F7
//#eedaf2
//#e889e5
//#f573b4
//#f279b6
//#f07fb8

const Color wazzupButton = Color(0xFFdf8eb6);
const Color wazzupBackGround = Color(0xFFFFF5F7);

// eng
//pacifico
//bungeeShade
//courgette
//lobster
//mali
//gochiHand
//architectsDaughter
//atma

// kor
// jua
// gaegu

// 앱바 wazzup글씨 볼드 테마
final TextStyle wazzupBarFont = GoogleFonts.gaegu(
  fontSize: 20,
  fontWeight: FontWeight.w500
);

// 기본 글 씨 테마 알아서 크기 조정하고 굵기 조정하셈
  final TextStyle wazzupFont = GoogleFonts.mali();

// 타이틀/헤더(앱 최상단)
final TextStyle headerFont = GoogleFonts.fredoka(
  fontSize: 28,
  fontWeight: FontWeight.w700,
);

// 섹션 제목(페이지 내 특정 컨텐츠 블럭)
final TextStyle sectionTitleFont = GoogleFonts.fredoka(
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

// 본문제목(카드 내부)
final TextStyle cardTitleFont = GoogleFonts.fredoka(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

// 본문(카드 내부)
final TextStyle cardBodyFont = GoogleFonts.fredoka(
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

// 보조 텍스트(부가 정보 작성할경우 ex) "호스트 외 15명 참여")
final TextStyle captionLabelFont = GoogleFonts.fredoka(
  fontSize: 12,
  color: Colors.grey[600],
);
