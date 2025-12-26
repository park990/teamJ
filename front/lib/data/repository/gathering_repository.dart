import 'package:front/screen/gathering_screen/model/gathering_meeting.dart';
import 'package:front/screen/gathering_screen/model/gathering_keyword_model.dart';

List<GatheringMeeting> meetings = [
    //더미데이터
    GatheringMeeting(
      cardTitle: '96년생 모여라~!',
      cardBody: '동갑 친구들끼리 허심탄회하게 얘기해봐용',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 1,
    ),
    GatheringMeeting(
      cardTitle: '여미새 남미새 다 모여라~~',
      cardBody: '매력발산 시작~',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 3,
    ),
    GatheringMeeting(
      cardTitle: 'TeamJ',
      cardBody: '코딩 쌉고수 모임',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 3,
    ),
    GatheringMeeting(
      cardTitle: '감기퇴치',
      cardBody: '코감기, 목감기 환자들 모여라!',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 2,
    ),
    GatheringMeeting(
      cardTitle: '당근중독',
      cardBody: '당근 말기환자들 모임',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 1,
    ),
  ];

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
      title: '두바이쫀득쿠키',
      slug: 'dubaiCookie'
    ),
    GatheringKeywordModel(
      title: '스포츠',
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
  ];