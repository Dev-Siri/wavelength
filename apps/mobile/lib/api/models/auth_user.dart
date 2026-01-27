class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;

  AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  Map<String, String> toJson() {
    return {
      "id": id,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
    };
  }
}
