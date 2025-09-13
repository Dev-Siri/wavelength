import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist_extra.dart";
import "package:wavelength/api/models/individual_artist.dart";
import "package:wavelength/constants.dart";

class ArtistRepo {
  static Future<ApiResponse<IndividualArtist>> fetchArtist({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/artists/$browseId"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<IndividualArtist>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = (decodedJson["success"] as bool);

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: IndividualArtist.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<ArtistExtra>> fetchArtistExtra({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/artists/$browseId/extra"),
      );

      final decodedResponse = await compute<String, ApiResponse<ArtistExtra>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: ArtistExtra.fromJson(decodedJson["data"]),
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
