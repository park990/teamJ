import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


  const Color wazzupButton = Color(0xFFeedaf2);


  // 앱바 wazzup글씨 볼드 테마
  final TextStyle wazzupBarFont = GoogleFonts.ibmPlexSans(
  fontSize: 20, 
  fontWeight: FontWeight.w500, 
);

  // 기본 글 씨 테마 알아서 크기 조정하고 굵기 조정하셈
  final TextStyle wazzupFont = GoogleFonts.ibmPlexSans(
);

// 타이틀/헤더
final TextStyle headerFont = GoogleFonts.ibmPlexSans(
  fontSize: 28,
  fontWeight: FontWeight.w700,
);

// 섹션 제목
final TextStyle subTitleFont = GoogleFonts.ibmPlexSans(
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

// 본문
final TextStyle bodyFont = GoogleFonts.ibmPlexSans(
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

// 보조 텍스트
final TextStyle labelFont = GoogleFonts.ibmPlexSans(
  fontSize: 12,
);
