import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/models/video.dart";
import "package:wavelength/constants.dart";

class SearchRepo {
  static Future<ApiResponse<List<Track>>> fetchTracksByQuery({
    required String query,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/search?q=$query"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<List<Track>>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final listOfItems = decodedJson["data"]["result"] as List?;

          if (listOfItems == null) return ApiResponseSuccess(data: []);

          return ApiResponseSuccess(
            data: listOfItems
                .map((final track) => Track.fromJson(track))
                .toList(),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<List<Video>>> fetchVideosByQuery({
    required String query,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/search/uvideos?q=$query"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<List<Video>>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final listOfItems = decodedJson["data"] as List?;

          if (listOfItems == null) return ApiResponseSuccess(data: []);

          return ApiResponseSuccess(
            data: listOfItems
                .map((final video) => Video.fromJson(video))
                .toList(),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<List<Artist>>> fetchArtistsByQuery({
    required String query,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/artists/search?q=$query&searchType=artists"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<List<Artist>>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final listOfItems = decodedJson["data"]["result"] as List?;

          if (listOfItems == null) return ApiResponseSuccess(data: []);

          return ApiResponseSuccess(
            data: listOfItems
                .map((final artist) => Artist.fromJson(artist))
                .toList(),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }
}
