import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/models/video.dart";
import "package:wavelength/constants.dart";

class SearchRepo {
  static Future<ApiResponse> fetchTracksByQuery({required String query}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/search?q=$query"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);

        final decodedData = ApiResponse.fromJson(decodedJson, (data) {
          final listOfItems = data["result"] as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final track) => Track.fromJson(track))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchVideosByQuery({required String query}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/search/uvideos?q=$query"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (data) {
          final listOfItems = data as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final video) => Video.fromJson(video))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchArtistsByQuery({
    required String query,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/search?q=$query&searchType=artists"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);

        final decodedData = ApiResponse.fromJson(decodedJson, (data) {
          final listOfItems = data["result"] as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final artist) => Artist.fromJson(artist))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
