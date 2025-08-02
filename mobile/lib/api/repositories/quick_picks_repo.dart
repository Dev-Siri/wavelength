import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/constants.dart";

class QuickPicksRepo {
  static Future<ApiResponse> fetchQuickPicks({required String locale}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/music/quick-picks?regionCode=$locale"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (quickPicks) {
          final listOfItems = quickPicks as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final quickPick) => QuickPicksItem.fromJson(quickPick))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
