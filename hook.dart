import 'dart:io';
import 'dart:convert' show UTF8;
import 'package:crypto/crypto.dart' show SHA1, HMAC, CryptoUtils;

void main() {
  var env = Platform.environment;
  var token = env["GITHUB_TOKEN"];

  if (token == null) {
    throw new Exception("GITHUB_TOKEN is not set in environment variables.");
  }

  HttpServer.bind("stacktrace.ca", 3001)
  .then((HttpServer server) {
    print('listening on localhost, port ${server.port}');
    server.listen((HttpRequest request) {
      String signature = request.headers.value("x-hub-signature");
      var sha = new HMAC(new SHA1(), UTF8.encode(token));
      request.listen((data) {
        sha.add(data);
        var digest = sha.close();
        var hash = CryptoUtils.bytesToHex(digest);
        if (signature == "sha1=$hash") {
          Process.start("./start-server.sh", []).then((Process process) {
            process.stdout
            .transform(UTF8.decoder)
            .listen((data) => print(data));
          });
        }
      });

      request.response.close();
    });
  }).catchError((e) => print(e.toString()));
}

