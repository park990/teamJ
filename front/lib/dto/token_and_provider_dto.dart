class TokenAndProviderDto {
  final String? provider;
  final String? socialToken;

  TokenAndProviderDto({
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