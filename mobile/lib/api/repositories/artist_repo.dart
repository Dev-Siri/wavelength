import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist_extra.dart";
import "package:wavelength/api/models/individual_artist.dart";
import "package:wavelength/constants.dart";

class ArtistRepo {
  static Future<ApiResponse> fetchArtist({required String browseId}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/artists/$browseId"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);

        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (artist) => IndividualArtist.fromJson(artist),
        );
        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchArtistExtra({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/artists/$browseId/extra"),
      );

      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);

        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (artistExtra) => ArtistExtra.fromJson(artistExtra),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
