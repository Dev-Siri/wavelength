import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:wavelength/api/models/local_google_sign_in_account.dart";

Future<LocalGoogleSignInAccount> stringMapToGoogleSignInAccount(
  String stringifiedUser,
) async {
  final FutureOr<Map<String, dynamic>> userJson = await compute(
    (data) => jsonDecode(data),
    stringifiedUser,
  );

  return LocalGoogleSignInAccount.fromJson(await userJson);
}

Map<String, String?> googleSignInAccountToMap(
  GoogleSignInAccount googleSignInUser,
) {
  return {
    "displayName": googleSignInUser.displayName,
    "photoUrl": googleSignInUser.photoUrl,
    "serverAuthCode": googleSignInUser.serverAuthCode,
    "email": googleSignInUser.email,
    "id": googleSignInUser.id,
  };
}

LocalGoogleSignInAccount googleSignInAccountToLocalAccount(
  GoogleSignInAccount googleSignInUser,
) {
  return LocalGoogleSignInAccount(
    id: googleSignInUser.id,
    email: googleSignInUser.email,
    displayName: googleSignInUser.displayName,
    photoUrl: googleSignInUser.photoUrl,
    serverAuthCode: googleSignInUser.serverAuthCode,
  );
}
