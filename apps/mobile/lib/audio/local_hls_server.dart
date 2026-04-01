import "dart:io";

class LocalHlsServer {
  HttpServer? _server;

  Future<int> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
      ..listen((HttpRequest request) async {
        final rawPath = request.uri.path;

        final decodedPath = Uri.decodeComponent(rawPath);
        final file = File(decodedPath);

        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          if (decodedPath.endsWith(".m3u8")) {
            request.response.headers.contentType = ContentType(
              "application",
              "vnd.apple.mpegurl",
            );
          } else if (decodedPath.endsWith(".m4s") ||
              decodedPath.endsWith(".mp4") ||
              decodedPath.endsWith(".m4a")) {
            request.response.headers.contentType = ContentType("video", "mp4");
          }

          request.response.add(bytes);
        } else {
          request.response.statusCode = 404;
        }

        await request.response.close();
      });

    return _server!.port;
  }

  void stop() {
    _server?.close();
  }
}
