import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/lyric.dart";
import "package:wavelength/api/models/music_video_preview.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/constants.dart";

class TrackRepo {
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

  static Future<ApiResponse> toggleTrackFromPlaylist({
    required String playlistId,
    required VideoType videoType,
    required Track track,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/playlists/$playlistId/tracks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "author": track.author,
          "thumbnail": track.thumbnail,
          "duration": track.duration,
          "isExplicit": track.isExplicit,
          "title": track.title,
          "videoId": track.videoId,
          "videoType": videoType == VideoType.track ? "track" : "uvideo",
        }),
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

  static Future<ApiResponse> fetchTrackLyrics({required String trackId}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/$trackId/lyrics"),
      );
      final decodedResponse = await compute((lyricsResponse) {
        final decodedJson = jsonDecode(lyricsResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (lyrics) => lyrics.map((lyric) => Lyric.fromJson(lyric)).toList(),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
