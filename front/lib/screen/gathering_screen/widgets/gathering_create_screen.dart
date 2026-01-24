import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class GatheringCreateScreen extends ConsumerStatefulWidget{
  const GatheringCreateScreen({
    super.key,
  });

  @override
  ConsumerState<GatheringCreateScreen> createState() => _GatheringCreateScreenState();
}

class _GatheringCreateScreenState extends ConsumerState<GatheringCreateScreen> {
  final _roomNameController = TextEditingController();
  final _roomDescController = TextEditingController();
  final _maxController = TextEditingController();

  // 태그 선택을 위한 state 변수
  String? _selectedRoomType;
  String? _selectedRegion;

  // 이미지 파일 변수
  XFile? _selectedImage;

  // 포커스 노드 생성
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  // 리스너 등록
  @override
  void initState() {
    super.initState();
    // 이름 노드 리스너
    _nameFocusNode.addListener(() {
      setState(() {}); // 포커스 잡히면/풀리면 화면 다시 그림
    });
    // 설명 노드 리스너
    _descFocusNode.addListener(() {
      setState(() {});
    });
  }
  // dispose() 메서드 - 메모리 누수 방지
  @override
  void dispose() {
    _roomNameController.dispose();
    _roomDescController.dispose();
    _maxController.dispose();
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  // 이미지 선택 메서드
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    // 선택된 이미지가 있다면 상태 업데이트
    if(image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }
  
  // TODO: _submitGathering() 메서드 작성
  Future<void> _submitGathering() async {
    
  }

  // iOS 스타일 태그 위젯
  Widget _buildTagChip({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
              ? wazzupButton // 선택됨: 분홍
              : CupertinoColors.systemGrey6, // 선택안됨: 회색
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                ? CupertinoColors.white // 선택됨: 흰색
                : CupertinoColors.black, // 선택안됨: 검정
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              letterSpacing: -0.3,
            ),
          ),
        ),
      );
    }

  // TODO: build() 메서드 작성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 생성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 모임 이름 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "모임 이름",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5
                ),
                TextField(
                  focusNode: _nameFocusNode,
                  controller: _roomNameController,
                  decoration: InputDecoration(
                    // 포커싱 일 경우에만 텍스트 보여주기
                    hintText: _nameFocusNode.hasFocus
                      ? '예: 한강 러닝 크루'
                      : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10
            ),
            // 모임 타입 설정
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "모임 타입 ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 12
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '등산', '운동', '개발', '스터디', '게임', '유흥', 'DIY', '챌린지',
                    ]
                      .map((type) {
                        return _buildTagChip(
                          label: type,
                          isSelected: _selectedRoomType == type,
                          onTap: () => setState(() => _selectedRoomType = type),
                        );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            // 모임 설명 - 500자 이내(텍스트 박스)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "모임 내용",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  focusNode: _descFocusNode,
                  controller: _roomDescController,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 500,
                  decoration: InputDecoration(
                    hintText: _descFocusNode.hasFocus
                      ? "모임정보를 적어주세요. (예: 인천 두쫀쿠 성지)"
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  contentPadding: EdgeInsets.all(16),
                  ),
                  // 상태 연결
                ),
              ],
            ),
            SizedBox(height: 24),
            // 모임 지역 - 서울, 인천, 경기 등
            Text(
              '지역', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '서울', '경기', '인천', '부산', '대구', '광주', '대전',
                '경주', '제주', '울릉', '천안', '강원', '신안', '해남',
                '백령',
              ]
                .map((region) {
                  return _buildTagChip(
                    label: region,
                    isSelected: _selectedRegion == region,
                    onTap: () => setState(() => _selectedRegion = region),
                  );
                }).toList(),
            ),
            SizedBox(height: 12),
            // 최대 인원수
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "최대 인원수",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 이미지 선택 UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "모임 이미지",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // 사진 선택 감지
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.camera,
                              size: 48,
                              color: CupertinoColors.systemGrey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '이미지 선택',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32
            ),
            CupertinoButton.filled(
              onPressed: _submitGathering,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                '모임 생성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}