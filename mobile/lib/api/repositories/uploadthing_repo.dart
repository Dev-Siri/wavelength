import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/uploadthing_file.dart";
import "package:wavelength/constants.dart";

class UploadThingRepo {
  static Future<ApiResponse<UploadThingFile>> uploadImage(
    XFile imageFile,
  ) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse("$backendUrl/uploadthing/manual-upload"),
        body: fileBytes,
        headers: {
          "Content-Type": imageFile.mimeType ?? "application/octet-stream",
        },
      );

      final decodedResponse =
          await compute<String, ApiResponse<UploadThingFile>>((fileResponse) {
            final decodedJson = jsonDecode(fileResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: UploadThingFile.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }
}
