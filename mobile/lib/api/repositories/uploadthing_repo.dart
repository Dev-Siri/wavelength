import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/uploadthing_file.dart";
import "package:wavelength/constants.dart";

class UploadThingRepo {
  static Future<ApiResponse> uploadImage(XFile imageFile) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse("$backendUrl/uploadthing/manual-upload"),
        body: fileBytes,
        headers: {
          "Content-Type": imageFile.mimeType ?? "application/octet-stream",
        },
      );

      final decodedResponse = await compute((fileResponse) {
        final decodedJson = jsonDecode(fileResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (data) => UploadThingFile.fromJson(data),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (err) {
      return ApiResponse(success: false, data: null);
    }
  }
}
