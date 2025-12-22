import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/screen/gathering_screen/model/gathering_meeting.dart';

class GatheringMeetingProvider extends Notifier<List<GatheringMeeting>>{
  @override
  List<GatheringMeeting> build() {
    return meetings;
  }
}

final gatheringMeetingProvider = NotifierProvider<GatheringMeetingProvider, List<GatheringMeeting>>((){
  return GatheringMeetingProvider();
});