import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/constants.dart";

class PlaylistsRepo {
  static Future<ApiResponse> fetchPublicPlaylists({required String? q}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists${q != null ? "?q=$q" : ""}"),
      );
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (playlists) {
          final listOfItems = playlists as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final playlist) => Playlist.fromJson(playlist))
              .toList();
        });

        return decodedData;
      }, response.body);

      print(decodedResponse);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
