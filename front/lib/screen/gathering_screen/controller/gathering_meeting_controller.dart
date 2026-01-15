import 'package:flutter/material.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/dto/gatherings/gathering_detail_dto.dart';

class GatheringMeetingController extends ChangeNotifier{
  
  final GatheringRepository repository;
  // nullable
  GatheringDetailDto? detailDto;
  
  bool isLoading = false;
  
  //생성자
  GatheringMeetingController({
    required this.repository,
  });
}