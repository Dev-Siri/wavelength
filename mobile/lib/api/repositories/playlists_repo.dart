import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class PlaylistsRepo {
  static Future<ApiResponse<List<Playlist>>> fetchUserPlaylists({
    required String email,
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/playlists/user/$email"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<Playlist>>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"]["playlists"] as List?;

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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "PlaylistsRepo.fetchUserPlaylists",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<Playlist>>> fetchPublicPlaylists({
    required String? q,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/playlists${q != null ? "?q=$q" : ""}"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<Playlist>>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"]["playlists"] as List?;

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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "PlaylistsRepo.fetchPublicPlaylists",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<PlaylistTrack>>> fetchPlaylistTracks({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId/tracks"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<PlaylistTrack>>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems =
                  decodedJson["data"]["playlistTracks"] as List?;

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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "PlaylistsRepo.fetchPlaylistTracks",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<PlaylistTracksLength>> fetchPlaylistTracksLength({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId/length"),
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
                  decodedJson["data"]["playlistTracksLength"],
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
        source: "PlaylistsRepo.fetchPlaylistTracksLength",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> createPlaylist({
    required String authToken,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/playlists/user/$email"),
        headers: {"Authorization": "Bearer $authToken"},
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
        source: "PlaylistsRepo.createPlaylist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> deletePlaylist({
    required String playlistId,
    required String authToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId"),
        headers: {"Authorization": "Bearer $authToken"},
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
        source: "PlaylistsRepo.deletePlaylist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> editPlaylist({
    required String playlistName,
    required String? coverImage,
    required String playlistId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId"),
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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "PlaylistsRepo.editPlaylist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> togglePlaylistVisibility({
    required String playlistId,
    required String authToken,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("$apiGatewayUrl/playlists/playlist/$playlistId/visibility"),
        headers: {"Authorization": "Bearer $authToken"},
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
        source: "PlaylistsRepo.togglePlaylistVisibility",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
