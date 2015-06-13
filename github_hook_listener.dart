library github_hook_listener;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'package:crypto/crypto.dart' show SHA1, HMAC, CryptoUtils;
import 'environment_checker.dart';
import 'project_deployer.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'dart:async';

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
    io.serve(handleGitHubHooks, '0.0.0.0', config['listeningPort']).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
  }

  Future<shelf.Response> handleGitHubHooks(shelf.Request request) async {
    await for (List<int> data in request.read()) {
      if (!xHubSignatureFitsOurs(request.headers["x-hub-signature"], data)) {
        return new shelf.Response.forbidden("");
      }

      var payload = JSON.decode(new String.fromCharCodes(data));
      if (wasPushOnMaster(payload['ref'])) {
        print("Hooked on push on $targetBranch");
        deployer.gitPull().then((_) => deployer
            .gitReset()
            .then((_) => deployer.upgradeServerDependencies())
            .then((_) => deployer.startServer())
            .then((_) => deployer.deployClient()));
      }
    }

    return new shelf.Response.ok("");
  }
}
