import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/constants.dart";

class PlaylistsRepo {
  static Future<ApiResponse<List<Playlist>>> fetchUserPlaylists({
    required String email,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/user/$email"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<Playlist>>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"] as List?;

              if (listOfItems == null) return ApiResponseSuccess(data: []);

              return ApiResponseSuccess(
                data: listOfItems
                    .map((final playlist) => Playlist.fromJson(playlist))
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

  static Future<ApiResponse<List<Playlist>>> fetchPublicPlaylists({
    required String? q,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists${q != null ? "?q=$q" : ""}"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<Playlist>>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"] as List?;

              if (listOfItems == null) return ApiResponseSuccess(data: []);

              return ApiResponseSuccess(
                data: listOfItems
                    .map((final playlist) => Playlist.fromJson(playlist))
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

  static Future<ApiResponse<List<PlaylistTrack>>> fetchPlaylistTracks({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/playlist/$playlistId/tracks"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<PlaylistTrack>>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"] as List?;

              if (listOfItems == null) return ApiResponseSuccess(data: []);

              return ApiResponseSuccess(
                data: listOfItems
                    .map((final track) => PlaylistTrack.fromJson(track))
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

  static Future<ApiResponse<PlaylistTracksLength>> fetchPlaylistTracksLength({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/playlist/$playlistId/length"),
      );
      final decodedResponse =
          await compute<String, ApiResponse<PlaylistTracksLength>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: PlaylistTracksLength.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }

  static Future<ApiResponse<String>> createPlaylist({
    required String email,
    required String username,
    required String image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$backendUrl/playlists/user/$email?authorName=$username&authorImage=$image",
        ),
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

  static Future<ApiResponse<String>> deletePlaylist({
    required String playlistId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$backendUrl/playlists/playlist/$playlistId"),
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

  static Future<ApiResponse<String>> editPlaylist({
    required String playlistName,
    required String? coverImage,
    required String playlistId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$backendUrl/playlists/playlist/$playlistId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": playlistName, "coverImage": coverImage}),
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

  static Future<ApiResponse<String>> togglePlaylistVisibility({
    required String playlistId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("$backendUrl/playlists/playlist/$playlistId/visibility"),
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
}
