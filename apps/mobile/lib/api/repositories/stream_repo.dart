import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/playability_status.dart";
import "package:wavelength/api/models/enums/stream_record_type.dart";
import "package:wavelength/api/models/stream.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/constants.dart";

class StreamRepo {
  static var wavelengthClient = Platform.isIOS ? "IOS" : "ANDROID";

  static Future<ApiResponse<PlayabilityStatus>> fetchStreamPlayabilityStatus({
    required String authToken,
    required String videoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$playerGatewayUrl/streams/$videoId/playability-status"),
        headers: {
          "Authorization": "Bearer $authToken",
          "X-Wavelength-Client": wavelengthClient,
        },
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<PlayabilityStatus>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: PlayabilityStatusParser.fromEnumString(
                  decodedJson["data"]["playabilityStatus"],
                ),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "StreamRepo.fetchStreamPlayabilityStatus",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<HlsStreamSource>> fetchStreamSource({
    required String videoId,
    required String authToken,
    required String preferredQuality,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$playerGatewayUrl/streams/$videoId?preferredQuality=$preferredQuality",
        ),
        headers: {
          "Authorization": "Bearer $authToken",
          "X-Wavelength-Client": wavelengthClient,
        },
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<HlsStreamSource>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: HlsStreamSource.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, utf8BodyDecoded);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "StreamRepo.fetchStreamSource",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<void> collectStream({required String videoId}) =>
      http.post(Uri.parse("$playerGatewayUrl/collector/$videoId"));

  static Future<void> recordStream({
    required QueueableMusic track,
    required StreamRecordType type,
  }) async {
    try {
      await http.post(
        Uri.parse("$apiGatewayUrl/streams/record"),
        body: jsonEncode({
          "type": type.name,
          "timestamp": DateTime.now().toUtc().toIso8601String(),
          "track": track.toJson(),
        }),
        headers: {"Content-Type": "application/json"},
      );
    } catch (_) {
      // Analytics collection so failure is fine to be left ignored.
    }
  }
}
