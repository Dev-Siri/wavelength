class LocalGoogleSignInAccount {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? serverAuthCode;

  LocalGoogleSignInAccount({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.serverAuthCode,
  });

  factory LocalGoogleSignInAccount.fromJson(Map<String, dynamic> json) {
    return LocalGoogleSignInAccount(
      id: json["id"],
      displayName: json["displayName"],
      email: json["email"],
      photoUrl: json["photoUrl"],
      serverAuthCode: json["serverAuthCode"],
    );
  }
}
