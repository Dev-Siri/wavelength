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
  static Future<ApiResponse<MusicVideoPreview>> fetchTrackMusicVideo({
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
      final decodedResponse =
          await compute<String, ApiResponse<MusicVideoPreview>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: MusicVideoPreview.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<String>> toggleTrackFromPlaylist({
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

      final decodedResponse = await compute<String, ApiResponse<String>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(data: decodedJson["data"] as String);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<List<Lyric>>> fetchTrackLyrics({
    required String trackId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/$trackId/lyrics"),
      );
      final decodedResponse = await compute<String, ApiResponse<List<Lyric>>>((
        lyricsResponse,
      ) {
        final decodedJson = jsonDecode(lyricsResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final lyrics = decodedJson["data"] as List;

          return ApiResponseSuccess(
            data: lyrics.map((lyric) => Lyric.fromJson(lyric)).toList(),
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
