import "package:hive/hive.dart";

part "auth_user.g.dart";

@HiveType(typeId: 16)
class AuthUser {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String displayName;
  @HiveField(3)
  final String? pictureUrl;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.pictureUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json["userId"] as String,
      email: json["email"] as String,
      displayName: json["displayName"] as String,
      pictureUrl: json["pictureUrl"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "email": email,
      "displayName": displayName,
      "pictureUrl": pictureUrl,
    };
  }
}
