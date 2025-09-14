import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playback_stream.dart";
import "package:wavelength/constants.dart";

class StreamsRepo {
  static Future<ApiResponse<PlaybackStream>> fetchAudioStreamPlaybackUrl({
    required String videoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/streams/playback/$videoId/audio"),
      );
      final decodedResponse =
          await compute<String, ApiResponse<PlaybackStream>>((stringResponse) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: PlaybackStream.fromJson(decodedJson["data"]),
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
