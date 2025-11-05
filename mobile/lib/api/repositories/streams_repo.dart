import "dart:typed_data";

import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/utils/url.dart";

class StreamsRepo {
  static Future<ApiResponse<Uint8List>> fetchTrackStream({
    required String videoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(getTrackPlaybackUrl(videoId, StreamPlaybackType.audio)),
      );

      return ApiResponseSuccess(data: response.bodyBytes);
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }
}
