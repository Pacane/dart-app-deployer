library environment_checker;

import 'dart:io';

class EnvironmentChecker {
  get githubToken => Platform.environment["GITHUB_TOKEN"];
}