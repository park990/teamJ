import 'dart:convert';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/gathering_newList_dto.dart';
import 'package:front/screen/gathering_screen/model/gathering_keyword_model.dart';
import 'package:front/dto/gathering_hotList_dto.dart';

class GatheringRepository {
  final ApiClient apiClient;
  // 생성자
  GatheringRepository(this.apiClient);

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
      slug: 'sports'
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

// List<GatheringMeetingModel> meetings = [
//     //더미데이터
//     GatheringMeetingModel(
//       title: '96년생 모여라~!',
//       content: '동갑 친구들끼리 허심탄회하게 얘기해봐용',
//       imageUrl: 'asset/img/image.png',
//       currentParticipants: 1,
//     ),
//     GatheringMeetingModel(
//       title: '여미새 남미새 다 모여라~~',
//       content: '매력발산 시작~',
//       imageUrl: 'asset/img/image.png',
//       currentParticipants: 3,
//     ),
//     GatheringMeetingModel(
//       title: 'TeamJ',
//       content: '코딩 쌉고수 모임',
//       imageUrl: 'asset/img/image.png',
//       currentParticipants: 3,
//     ),
//     GatheringMeetingModel(
//       title: '감기퇴치',
//       content: '코감기, 목감기 환자들 모여라!',
//       imageUrl: 'asset/img/image.png',
//       currentParticipants: 2,
//     ),
//     GatheringMeetingModel(
//       title: '당근중독',
//       content: '당근 말기환자들 모임',
//       imageUrl: 'asset/img/image.png',
//       currentParticipants: 1,
//     ),
//   ];
