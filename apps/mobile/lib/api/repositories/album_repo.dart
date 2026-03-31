import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/saved_album.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class AlbumRepo {
  static Future<ApiResponse<Album>> fetchAlbum({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/album/$browseId"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<Album>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: Album.fromJson(decodedJson["data"]["album"]),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.fetchAlbum",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String?>> fetchLiveAlbumCover({
    required String albumId,
    required String videoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/album/$albumId/$videoId/cover"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<String?>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["liveAlbumCoverUri"] as String?,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.fetchLiveAlbumCover",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<SavedAlbum>>> fetchSavedAlbums({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/saves"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<SavedAlbum>>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = (decodedJson["success"] as bool);

            if (isSuccessful) {
              final albums = decodedJson["data"]["albums"] as List?;
              return ApiResponseSuccess(
                data:
                    albums
                        ?.map((album) => SavedAlbum.fromJson(album))
                        .toList() ??
                    [],
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.fetchSavedAlbums",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<bool>> fetchIsAlbumSaved({
    required String albumId,
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/album/$albumId/is-saved"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<bool>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["isSaved"] as bool,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.fetchIsAlbumSaved",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<void>> saveAlbum({
    required String albumId,
    required String authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/albums/album/$albumId/save"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<void>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(data: null);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.saveAlbum",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<bool>> fetchIsAlbumLossless({
    required String albumId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/albums/album/$albumId/is-lossless"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<bool>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["isLossless"] as bool,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AlbumRepo.fetchIsAlbumLossless",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
