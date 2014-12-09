import 'dart:io';
import 'dart:convert' show UTF8;
import 'package:crypto/crypto.dart' show SHA1, HMAC, CryptoUtils;

Process serverProcess;
Process clientProcess;

void main() {
  var env = Platform.environment;
  var token = env["GITHUB_TOKEN"];

//  if (token == null) {
//    throw new Exception("GITHUB_TOKEN is not set in environment variables.");
//  }

  HttpServer.bind("localhost", 3002)
  .then((HttpServer server) {
    print('listening on localhost, port ${server.port}');
    server.listen((HttpRequest request) {
//      String signature = request.headers.value("x-hub-signature");
//      var sha = new HMAC(new SHA1(), UTF8.encode(token));
      request.listen((data) {
//        sha.add(data);
//        var digest = sha.close();
//        var hash = CryptoUtils.bytesToHex(digest);
//        if (signature == "sha1=$hash") {
        if (1 == 1) {
          print("if");
          if (serverProcess != null) {
            print("killing server");
            serverProcess.kill();
          }

          if (clientProcess != null) {
            print("killing client");
            clientProcess.kill();
          }
          print("Resetting branch");
          ProcessResult result = Process.runSync("bash", ["-c", "git pull && git reset --hard origin/master"], workingDirectory: "/home/joel/code/dart/PokerPlanning");
          print(result.stdout);

          print("Starting server");
          Process.start("bash", ["-c", "dart main.dart"], workingDirectory : "/home/joel/code/dart/PokerPlanning/PokerPlanningServer").then((Process process) {
            serverProcess = process;
            process.stdout.transform(UTF8.decoder).listen((data) => print(data));
            process.stderr.transform(UTF8.decoder).listen((data) => print(data));
          });

          print("Starting client");
          Process.start("bash", ["-c", "pub serve --port 3000 --mode=release"], workingDirectory : "/home/joel/code/dart/PokerPlanning/PokerPlanningClient").then((Process process) {
            clientProcess = process;
            process.stdout.transform(UTF8.decoder).listen((data) => print(data));
            process.stderr.transform(UTF8.decoder).listen((data) => print(data));
          });
        }
      });

      request.response.close();
    });
  }).catchError((e) => print(e.toString()));
}
