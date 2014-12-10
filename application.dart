library application;

import 'github_hook_listener.dart';

class Application {
  GithubHookListener hookListener;

  Application(this.hookListener);

  void run() {
    hookListener.listen();
  }
}