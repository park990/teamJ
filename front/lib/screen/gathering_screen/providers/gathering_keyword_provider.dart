import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/screen/gathering_screen/model/gathering_keyword_model.dart';

class GatheringKeywordProvider extends Notifier<List<GatheringKeywordModel>>{
  @override
  List<GatheringKeywordModel> build() {
    debugPrint('키워드 목록: ${keywords}');
    /// 1. Repository에서 인스턴스 가져오기
    /// 반환 받을 키워드 데이터 변수(Repository)
    return keywords;
  }
}

final gatheringKeywordProvider =
  NotifierProvider<GatheringKeywordProvider, List<GatheringKeywordModel>>((){
  return GatheringKeywordProvider();
});