import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class AlbumRepo {
  static Future<ApiResponse<Album>> fetchAlbum({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/album/$browseId"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<Album>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: Album.fromJson(decodedJson["data"]["album"]),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ArtistRepo.fetchArtist",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
