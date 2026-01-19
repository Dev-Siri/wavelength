import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class ArtistRepo {
  static Future<ApiResponse<Artist>> fetchArtist({
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/artists/artist/$browseId"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<Artist>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: Artist.fromJson(decodedJson["data"]["artist"]),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ArtistRepo.fetchArtist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<List<FollowedArtist>>> fetchFollowedArtists({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/artists/followed"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<FollowedArtist>>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = (decodedJson["success"] as bool);

            if (isSuccessful) {
              final artists = decodedJson["data"]["artists"] as List;

              return ApiResponseSuccess(
                data: artists
                    .map((artist) => FollowedArtist.fromJson(artist))
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
        source: "ArtistRepo.fetchFollowedArtists",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<bool>> fetchIsFollowingArtist({
    required String authToken,
    required String browseId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/artists/followed/$browseId/is-following"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<bool>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          final isFollowing = decodedJson["data"]["isFollowing"] as bool;

          return ApiResponseSuccess(data: isFollowing);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ArtistRepo.fetchIsFollowingArtist",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> followArtist({
    required String authToken,
    required String browseId,
    required String name,
    required String thumbnail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/artists/followed"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "browseId": browseId,
          "name": name,
          "thumbnail": thumbnail,
        }),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute<String, ApiResponse<String>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = (decodedJson["success"] as bool);

        if (isSuccessful) {
          final data = decodedJson["data"] as String;

          return ApiResponseSuccess(data: data);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ArtistRepo.followArtist",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
