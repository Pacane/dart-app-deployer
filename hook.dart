library github_deploying_app;

import 'application.dart';
import 'environment_checker.dart';
import 'config_loader.dart';
import 'github_hook_listener.dart';
import 'project_deployer.dart';
import 'dart:io';

main() async {
  ConfigLoader configLoader = new ConfigLoader();
  EnvironmentChecker environmentChecker = new EnvironmentChecker();

  Map config = await configLoader.loadConfig();
  assert(environmentChecker.githubToken != null);

  ProjectDeployer deployer = new ProjectDeployer(config);
  GithubHookListener hookListener = new GithubHookListener(environmentChecker, config, deployer);

  Application app = new Application(hookListener);

  app.run();

  ProcessSignal.SIGINT.watch().listen((ProcessSignal signal) {
    deployer.killServerProcess();

    exit(0);
  });

  ProcessSignal.SIGTERM.watch().listen((ProcessSignal signal) {
    deployer.killServerProcess();

    exit(0);
  });
}
