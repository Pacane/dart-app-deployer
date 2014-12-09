import 'dart:io';
import 'dart:convert' show UTF8;
import 'package:crypto/crypto.dart' show SHA1, HMAC, CryptoUtils;
import 'package:dart_config/default_server.dart';

Process serverProcess;

String token;

showLogs(Process process) {
  process.stdout.transform(UTF8.decoder).listen((data) => print(data));
  process.stderr.transform(UTF8.decoder).listen((data) => print(data));
}

void main() {
  var env = Platform.environment;
  token = env["GITHUB_TOKEN"];

  var listeningPort;
  var gitWorkingDir;
  var clientPath;
  var clientHostname;
  var websitePath;
  var serverPath;
  var serverFileName;
  var gitTarget;

  if (token == null) {
    throw new Exception("GITHUB_TOKEN is not set in environment variables.");
  }

  loadConfig()
  .then((Map config) {
    var checkNotNull = [];
    listeningPort = config["listeningPort"];
    gitWorkingDir = config["gitWorkingDir"];
    clientPath = config["clientPath"];
    websitePath = config["websitePath"];
    serverPath = config["serverPath"];
    serverFileName = config["serverFileName"];
    gitTarget = config["gitTarget"];
    clientHostname = config["clientHostname"];
    checkNotNull = [listeningPort, gitWorkingDir, clientPath, clientHostname, websitePath, serverPath, serverFileName, gitTarget];
    checkNotNull.forEach((e) {
      if ((e) == null) throw new Exception("Missing config entry.");
    });
  }).catchError((error) => print(error))
  .then((_) {
    HttpServer.bind(clientHostname, listeningPort)
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
            if (serverProcess != null) {
              print("killing server");
              serverProcess.kill();
            }

            print("Resetting branch");
            ProcessResult result = Process.runSync("bash", ["-c", "git pull && git reset --hard $gitTarget"], workingDirectory: gitWorkingDir);
            print(result.stdout);

            print("Starting server");
            Process.start("bash", ["-c", "dart $serverFileName"], workingDirectory : serverPath).then((Process process) {
              serverProcess = process;
              showLogs(process);
            });

            print("Deploying client");
            Process.start("bash", ["-c", "pub build"], workingDirectory : clientPath).then((Process process) => showLogs(process))
            .then((_) => Process.start("rm -rf $websitePath/* -r", [])).then((copyProcess) => showLogs(copyProcess))
            .then((_) => Process.start("cp $clientPath/build/web/* $websitePath -r", [])).then((copyProcess) => showLogs(copyProcess));
          }
        });

        request.response.close();
      });
    }).catchError((e) => print(e.toString()));
  });
}
