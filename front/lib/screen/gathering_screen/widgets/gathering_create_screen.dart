import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  // TODO: dispose() 메서드 작성
  @override
  void dispose() {
    _roomNameController.dispose();
    _roomDescController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // TODO: 이미지 선택 메서드
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
                  "모임 제목",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5
                ),
                TextField(
                  controller: _roomNameController,
                  decoration: const InputDecoration(
                    labelText: '모임 이름',
                    hintText: '예: 한강 러닝 크루',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10
            ),
            // 모임 타입 설정 - 취미, 운동, 자기계발 등
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "모임 타입",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5
                ),
                Wrap(
                  spacing: 8.0,
                  children: ['취미','운동','개발','스터디'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedRoomType == type, //현재 선택된 항목인지
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoomType = selected ? type : null; // 선택/해제
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // 모임 설명 - 500자 이내(텍스트 박스)
            TextFormField(
              controller: _roomDescController,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 500,
              decoration: InputDecoration(
                hintText: "모임정보를 적어주세요. (예: 인천 두쫀쿠 성지)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              // 상태 연결
            ),
            // 모임 지역 - 서울, 인천, 경기 등

            // 최대 인원수
            TextField(
              controller: _maxController,
            ),
            // TODO 5에서 여기에 이미지 선택 UI 추가
            
            const SizedBox(
              height: 32
            ),

            // 제출 버튼
            ElevatedButton(
              onPressed: _submitGathering,
              child: const Text('모임 생성'),
            ),
          ],
        ),
      ),
    );
  }
}