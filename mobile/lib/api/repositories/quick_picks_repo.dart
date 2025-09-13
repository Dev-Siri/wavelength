import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/constants.dart";

class QuickPicksRepo {
  static Future<ApiResponse<List<QuickPicksItem>>> fetchQuickPicks({
    required String locale,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/quick-picks?regionCode=$locale"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse =
          await compute<String, ApiResponse<List<QuickPicksItem>>>((
            stringResponse,
          ) {
            final decodedJson = jsonDecode(stringResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              final listOfItems = decodedJson["data"] as List?;

              if (listOfItems == null) return ApiResponseSuccess(data: []);

              return ApiResponseSuccess(
                data: listOfItems
                    .map(
                      (final quickPick) => QuickPicksItem.fromJson(quickPick),
                    )
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
}
