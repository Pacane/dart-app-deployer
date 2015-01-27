library github_hook_listener;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'package:crypto/crypto.dart' show SHA1, HMAC, CryptoUtils;
import 'environment_checker.dart';
import 'project_deployer.dart';

class GithubHookListener {
  EnvironmentChecker environmentChecker;
  Map config;
  ProjectDeployer deployer;
  String targetBranch;

  GithubHookListener(this.environmentChecker, this.config, this.deployer) {
    targetBranch = config["gitTarget"];
  }

  bool xHubSignatureFitsOurs(String signature, data) {
    var sha = new HMAC(new SHA1(), UTF8.encode(environmentChecker.githubToken));
    sha.add(data);
    var digest = sha.close();
    var hash = CryptoUtils.bytesToHex(digest);
    return signature == "sha1=$hash";
  }

  bool wasPushOnMaster(String ref) => ref == 'refs/heads/$targetBranch';

  listen() async {
    HttpServer server = await HttpServer.bind(config["clientHostname"], config["listeningPort"]);
    print('listening on localhost, port ${server.port}');

    server.listen((HttpRequest request) {
      request.listen((data) {
        if (xHubSignatureFitsOurs(request.headers.value("x-hub-signature"), data)) {
          request.response.close();
        }

        var payload = JSON.decode(new String.fromCharCodes(data));
        if (wasPushOnMaster(payload['ref'])) {
          print("Hooked on push on $targetBranch");
          deployer.resetAndPullBranch()
          .then((_) => deployer.upgradeServerDependencies())
          .then((_) => deployer.startServer())
          .then((_) => deployer.deployClient());
        }
      });
    });
    deployer.killServerProcess();
  }
}
