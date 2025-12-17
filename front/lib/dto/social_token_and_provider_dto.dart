class SocialTokenAndProviderDto {
  final String? provider;
  final String? socialToken;

  SocialTokenAndProviderDto({
    this.provider,
    this.socialToken,
  });

  Map<String,dynamic> toJson(){
    return {
      'socialToken':socialToken,
      'provider':provider,
    };
  }
}