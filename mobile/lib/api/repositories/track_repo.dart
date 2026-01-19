import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/liked_track.dart";
import "package:wavelength/api/models/lyric.dart";
import "package:wavelength/api/models/music_video_preview.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class TrackRepo {
  static Future<ApiResponse<MusicVideoPreview>> fetchTrackMusicVideo({
    required String title,
    required String artist,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$apiGatewayUrl/music/music-video-preview?title=$title&artist=$artist",
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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchTrackMusicVideo",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> toggleTrackFromPlaylist({
    required String playlistId,
    required String authToken,
    required VideoType videoType,
    required Track track,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId/tracks"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "artists": track.artists.map((artist) => artist.toJson()).toList(),
          "thumbnail": track.thumbnail,
          "duration": track.duration.toString(),
          "isExplicit": track.isExplicit,
          "title": track.title,
          "videoId": track.videoId,
          "videoType": videoType.name,
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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.toggleTrackFromPlaylist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<Lyric>>> fetchTrackLyrics({
    required String trackId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/$trackId/lyrics"),
      );
      final decodedResponse = await compute<String, ApiResponse<List<Lyric>>>((
        lyricsResponse,
      ) {
        final decodedJson = jsonDecode(lyricsResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final lyrics = decodedJson["data"]["lyrics"] as List;

          return ApiResponseSuccess(
            data: lyrics.map((lyric) => Lyric.fromJson(lyric)).toList(),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchTrackLyrics",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<int>> fetchTrackDuration({
    required String trackId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/$trackId/duration"),
      );
      final decodedResponse = await compute<String, ApiResponse<int>>((
        durationResponse,
      ) {
        final decodedJson = jsonDecode(durationResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final duration = decodedJson["data"]["durationSeconds"] as int;

          return ApiResponseSuccess(data: duration);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchTrackDuration",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<int>> fetchTrackLikeCount({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/likes/count"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final decodedResponse = await compute<String, ApiResponse<int>>((
        durationResponse,
      ) {
        final decodedJson = jsonDecode(durationResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          final likeCount = decodedJson["data"]["likeCount"] as int;

          return ApiResponseSuccess(data: likeCount);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchTrackLikeCount",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<LikedTrack>>> fetchLikedTracks({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/likes"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final decodedResponse =
          await compute<String, ApiResponse<List<LikedTrack>>>((
            durationResponse,
          ) {
            final decodedJson = jsonDecode(durationResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final likedTracks = decodedJson["data"]["likedTracks"] as List;

              return ApiResponseSuccess(
                data: likedTracks
                    .map((final likedTrack) => LikedTrack.fromJson(likedTrack))
                    .toList(),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchLikedTracks",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<PlaylistTracksLength>> fetchLikedTracksLength({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/likes/length"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final decodedResponse =
          await compute<String, ApiResponse<PlaylistTracksLength>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: PlaylistTracksLength.fromJson(
                  decodedJson["data"]["likedTracksLength"],
                ),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchLikedTracksLength",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> likeTrack({
    required String authToken,
    required Track track,
    required VideoType videoType,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("$apiGatewayUrl/music/track/likes"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "artists": track.artists.map((artist) => artist.toJson()).toList(),
          "thumbnail": track.thumbnail,
          "duration": track.duration.toString(),
          "isExplicit": track.isExplicit,
          "title": track.title,
          "videoId": track.videoId,
          "videoType": videoType.name,
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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.likeTrack",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<bool>> fetchIsAlreadyLiked({
    required String authToken,
    required String videoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/music/track/likes/$videoId/is-liked"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final decodedResponse = await compute<String, ApiResponse<bool>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["isLiked"] as bool,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "TrackRepo.fetchIsAlreadyLiked",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
