library application;

import 'environment_checker.dart';
import 'github_hook_listener.dart';
import 'config_loader.dart';
import 'dart:async';

class Application {
  GithubHookListener hookListener;

  Application(this.hookListener);

  void run() {
    hookListener.listen();
  }
}