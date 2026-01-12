class RandomMatchDto {
  final String status;     // "WAITING" | "MATCHED"
  final int? roomIdx;
  final int? partnerIdx;
  
  RandomMatchDto({
    required this.status,
    this.roomIdx,
    this.partnerIdx,
  });
  
  factory RandomMatchDto.fromJson(Map<String, dynamic> json) {
    return RandomMatchDto(
      status: json['status'],
      roomIdx: json['roomIdx'],
      partnerIdx: json['partnerIdx'],
    );
  }
  

  bool get isWaiting => status == 'WAITING';
  bool get isMatched => status == 'MATCHED';
  bool get isCancelled => status == 'CANCELLED';
}