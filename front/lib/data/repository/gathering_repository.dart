import 'dart:convert';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/gatherings/gathering_create_request_dto.dart';
import 'package:front/dto/gatherings/gathering_action_response_dto.dart';
import 'package:front/dto/gatherings/gathering_detail_dto.dart';
import 'package:front/dto/gatherings/gathering_newList_dto.dart';
import 'package:front/screen/gathering_screen/model/gathering_keyword_model.dart';
import 'package:front/dto/gatherings/gathering_hotList_dto.dart';
import 'package:image_picker/image_picker.dart';

class GatheringRepository {
  final ApiClient apiClient;
  // 생성자
  GatheringRepository(this.apiClient);

  //******** 모임 생성 ********/
  Future<GatheringActionResponseDto> createGathering({
    required GatheringCreateRequestDto dto,
    XFile? imageFile,
  }) async {
    // DTO 객체 → Map<String, dynamic> 변환 (toJson 메서드 사용)
    final dtoMap = dto.toJson();

    // Map → JSON String 변환 (HTTP 전송을 위해)
    final fields = {
      'data': jsonEncode(dtoMap),
    };

    // 이미지 리스트 준비
    final images = imageFile != null ? [imageFile] : <XFile>[];

    // Multipart 요청
    final response = await apiClient.postMultipart(
      '/api/gathering/create',
      fields: fields,
      images: images,
    );

    // 응답 파싱
    return _parseSingleResponse<GatheringActionResponseDto> (
      response,
      (json) => GatheringActionResponseDto.fromJson(json)
    );
  }

  //******** 모임 참가 요청 ********/
  Future<void> joinGathering(int roomIdx) async {
    final response = await apiClient.post('/api/gathering/join?roomIdx=${roomIdx}');
    if(response.statusCode != 200) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  //******** 모임 상세정보 조회 ********/
  Future<GatheringDetailDto> getGatheringDetail(int roomIdx) async {
    final response = await apiClient.get('/api/gathering/detail?roomIdx=${roomIdx}');
    return _parseSingleResponse<GatheringDetailDto>(
      response,
      (json) => GatheringDetailDto.fromJson(json)
    );
  }

  //******** 핫한 모임 불러오기 ********/
  Future<List<GatheringHotlistDto>> fetchHotGatherings() async {
    final response = await apiClient.get('/api/gathering/hotList');
    return _parseResponse<GatheringHotlistDto>(
      response,
      (json) => GatheringHotlistDto.fromJson(json)
    );
  }

  //******** 새로운 모임 불러오기 ********/
  Future<List<GatheringNewlistDto>> fetchNewGatherings() async {
    // 엔드포인트 호출
    final response = await apiClient.get('/api/gathering/newList');
    return _parseResponse<GatheringNewlistDto>(
      response,
      (json) => GatheringNewlistDto.fromJson(json)
    );
  }

  //******** 공통 파싱 함수 및 예외 처리 ********/
  List<T> _parseResponse<T>(dynamic response, T Function(Map<String, dynamic>) fromJson) {
    final body = utf8.decode(response.bodyBytes);
    // 에러 처리
    if(response.statusCode != 200) {
      throw Exception('데이터 조회 실패: ${response.statusCode}');
    }

    // JSON 파싱
    final json = jsonDecode(body);

    // 데이터 리스트 추출 (data 키값 확인 필요)
    List<dynamic> dataList;

    if(json is List) {
      // 백엔드 -> list로 줄 경우
      dataList = json;
    } else if (json is Map<String, dynamic> && json.containsKey('data')) {
      dataList = json['data'];
    } else {
      dataList = [];
    }

    // 객체 리스트로 변환해서 반환
    return dataList
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //******** 단일 객체 파싱 함수 ********/
  T _parseSingleResponse<T>(dynamic response, T Function(Map<String, dynamic>) fromJson) {
    final body = utf8.decode(response.bodyBytes);
    if(response.statusCode != 200) {
      throw Exception('데이터 조회 실패: ${response.statusCode}');
    }

    final json = jsonDecode(body);
    // ApiResponse { result, message, data: { ... } } 구조에서 data만 꺼냄
    dynamic data;
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      data = json['data'];
    } else {
      data = json;
    }

    return fromJson(data as Map<String, dynamic>);
  }
}


// === 더미데이터 ===
List<GatheringKeywordModel> keywords = [
    // 키워드 데이터
    GatheringKeywordModel(
      title: 'teamJ',
      slug: 'teamJ'
    ),
    GatheringKeywordModel(
      title: '맛집탐방',
      slug: 'foodTour'
    ),
    GatheringKeywordModel(
      title: '연애/결혼',
      slug: 'Love'
    ),
    GatheringKeywordModel(
      title: '영화',
      slug: 'movies'
    ),
    GatheringKeywordModel(
      title: '스포츠',
      slug: 'sports'
    ),
    GatheringKeywordModel(
      title: '두바이쫀득쿠키',
      slug: 'dubaiCookie'
    ),
  ];
