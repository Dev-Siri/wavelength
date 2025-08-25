import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/music_video_preview.dart";
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/constants.dart";

class TrackRepo {
  static Future<ApiResponse> fetchTrackThemeColor({
    required String trackId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/$trackId/theme-color"),
      );
      print(response.body);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (themeColor) => ThemeColor.fromJson(themeColor),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchTrackMusicVideo({
    required String trackId,
    required String title,
    required String artist,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$backendUrl/music/$trackId/music-video-preview?title=$title&artist=$artist",
        ),
      );
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (musicVideoPreview) => MusicVideoPreview.fromJson(musicVideoPreview),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> addTrackToPlaylist({
    required String playlistId,
  }) async {
    try {
      // TODO: Implement playlist track add.
      final response = await http.delete(
        Uri.parse("$backendUrl/playlists/$playlistId"),
      );

      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse<String>.fromJson(decodedJson, null);

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
