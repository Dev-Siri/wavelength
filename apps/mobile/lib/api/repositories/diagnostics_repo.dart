import "dart:convert";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:http/http.dart" as http;
import "package:wavelength/constants.dart";

class DiagnosticsRepo {
  static Future<void> reportError({
    required String error,
    required String source,
  }) async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) return;

    try {
      await http.post(
        Uri.parse("$apiGatewayUrl/diagnostics/report-error"),
        body: jsonEncode({
          "error": error,
          "source": source,
          "platform": wavelengthDiagnosticPlatformName,
        }),
        headers: {"Content-Type": "application/json"},
      );
    } catch (_) {
      // This is the last step of error handling, and we do not really care if this fails.
      // So this remains empty, the error diagnostic simply could not be sent to the server.
    }
  }
}
