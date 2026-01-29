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

  // 태그 검증 에러메시지를 위한 변수
  String? _roomNameError; // 모임 이름 에러
  String? _roomDescError; // 모임 설명 에러
  String? _roomTypeError; // 모임 타입 에러
  String? _regionError; // 지역에러
  String? _maxPeopleError; // 최대인원 에러

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
  
  // _submitGathering() 메서드 작성
  Future<void> _submitGathering() async {
    // 폼 검증: 필수 입력값 확인

    // 모든 검증을 hasCustomErrors로 통일
    bool hasCustomErrors = false;

    setState(() {
      // 모임 이름 검증
      if(_roomNameController.text.trim().isEmpty) {
        _roomNameError = "모임 이름을 입력해주세요";
        hasCustomErrors = true;
      } else if(_roomNameController.text.length > 30) {
        _roomNameError = "모임 이름은 30자 이내로 입력해주세요";
        hasCustomErrors = true;
      } else {
        _roomNameError = null;
      }

      // 모임 설명 검증
      final desc = _roomDescController.text.trim();
      if(desc.isNotEmpty && desc.length < 10) {
        _roomDescError = "모임 설명은 10자 이상 작성해주세요";
        hasCustomErrors = true;
      } else {
        _roomDescError = null;
      }

      // 모임 타입 체크
      if(_selectedRoomType == null) {
        setState(() {
          _roomTypeError = "모임 타입을 선택해주세요";
        });
        hasCustomErrors = true; // 에러 발생 표시
      } else {
        _roomTypeError = null; //선택되어 있으면 에러 초기화
      }
      // 지역 체크
      if(_selectedRegion == null) {
          _regionError = "지역을 선택해주세요";
        hasCustomErrors = true;
      } else {
        _regionError = null;
      }
      // 최대 인원 체크
      if(_maxController.text.trim().isEmpty) {
        _maxPeopleError = "최대 인원을 입력하세요";
        hasCustomErrors = true;
      } else {
        final maxPeople = int.tryParse(_maxController.text);
        if(maxPeople == null) {
          _maxPeopleError = "숫자만 입력 가능합니다.";
          hasCustomErrors = true;
        } else if(maxPeople < 2) {
          _maxPeopleError = "최소 2명 이상이어야 합니다.";
          hasCustomErrors = true;
        } else {
          _maxPeopleError = null;
        }
      }
    });

    // 검증 통과
    print('검증 통과! 서버 전송 준비 완료');
    print('모임 이름: ${_roomNameController.text.trim()}');
    print('모임 타입: ${_selectedRoomType}');
    print('지역: ${_selectedRegion}');
    print('최대 인원: ${_maxController.text}');

    // TODO: DTO 생성

    // TODO: Provider를 통해 서버로 전송

    // TODO: 생성 결과 확인

    // TODO: 성공 시: 모임 리스트 새로고침

    // TODO: 메인 화면 복귀(예외처리 필수)
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
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      if(value.trim().isEmpty) {
                        _roomNameError = "모임 이름을 입력해주세요";
                      } else {
                        return null;
                      }
                    });
                  },
                  focusNode: _nameFocusNode,
                  controller: _roomNameController,
                  decoration: InputDecoration(
                    // 포커싱일 경우에만 텍스트 보여주기
                    hintText: _nameFocusNode.hasFocus
                      ? '예: 한강 러닝 크루'
                      : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if(_roomNameError != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8, left: 12,
                    ),
                    child: Text(
                      _roomNameError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
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
                          onTap: () => setState(() {
                            _selectedRoomType = type;
                            _roomTypeError = null; // 선택하면 에러 초기화
                          }),
                        );
                  }).toList(),
                ),
                // 에러메시지
                if (_roomTypeError != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8, left: 12
                    ),
                    child: Text(
                      _roomTypeError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
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
                  onChanged: (value) {
                    setState(() {
                      if(value.trim().isEmpty) {
                        _roomNameError = "모임 내용을 입력해주세요";
                      } else {
                        return null;
                      }
                    });
                  },
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
                ),
                // 모임 내용 관련 에러메시지
                if(_roomDescError != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8, left: 12,
                    ),
                    child: Text(
                      _roomDescError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
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
                    onTap: () => setState(() {
                      _selectedRegion = region;
                      _regionError = null;
                    }),
                  );
                }).toList(),
            ),
            if(_regionError != null)
            Padding(
              padding: EdgeInsets.only(
                top: 8, left: 12
              ),
              child: Text(
                _regionError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
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
                      width: 100,
                      child: TextFormField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          // 에러 메시지가 여러 줄로 표시되도록 설정
                          errorMaxLines: 2,
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
                if(_maxPeopleError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _maxPeopleError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
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