import 'dart:io';
import 'dart:convert' show UTF8;
import 'dart:async';
import 'package:grinder/grinder_files.dart';

class ProjectDeployer {
  Map config;
  var clientPath;
  var gitTarget;
  var gitWorkingDir;
  var serverFileName;
  var serverPath;
  var websitePath;
  Process serverProcess;

  ProjectDeployer(this.config) {
    clientPath = config["clientPath"];
    gitTarget = config["gitTarget"];
    gitWorkingDir = config["gitWorkingDir"];
    serverFileName = config["serverFileName"];
    serverPath = config["serverPath"];
    websitePath = config["websitePath"];
  }

  Future gitPull() async {
    print("Pulling changes");

    ProcessResult result = await Process.run("git", ['pull'],
        workingDirectory: gitWorkingDir, runInShell: true);
    showLogsForProcessResult(result);
  }

  Future gitReset() async {
    print("Resetting branch");
    ProcessResult result = await Process.run(
        "git", ['reset', '--hard', 'origin/$gitTarget'],
        workingDirectory: gitWorkingDir);
    showLogsForProcessResult(result);
  }

  void showLogs(Process process) {
    process.stdout.transform(UTF8.decoder).listen((data) => print(data));
    process.stderr.transform(UTF8.decoder).listen((data) => print(data));
  }

  void showLogsForProcessResult(ProcessResult processResult) {
    print(processResult.stderr);
    print(processResult.stdout);
  }

  Future buildWebsite() async {
    print("Building website");
    ProcessResult result = await Process.run("pub", ['build', '--mode=release'],
        workingDirectory: clientPath);
    showLogsForProcessResult(result);
  }

  void killServerProcess() {
    if (serverProcess != null) {
      print("Killing server");
      serverProcess.kill();
    }
  }

  Future upgradeServerDependencies() async {
    ProcessResult result =
        await Process.run("pub", ['upgrade'], workingDirectory: serverPath);
    showLogsForProcessResult(result);
  }

  Future startServer() async {
    killServerProcess();

    print("Starting server");
    Process result = await Process.start("dart", ['$serverFileName'],
        workingDirectory: serverPath);
    serverProcess = result;
    showLogs(result);
  }

  Future deployNewSite() async {
    print("Deploying new site");
    var tree = new Directory('$clientPath/build/web').listSync();
    var websiteDirectory = new Directory('$websitePath');

    for (FileSystemEntity entity in tree) {
      if (entity is File) {
        copy(entity, websiteDirectory);
      } else {
        copy(entity, new Directory(
            entity.path.replaceAll('$clientPath/build/web', websitePath)));
      }
    }
  }

  Future removeOldWebsiteFiles() async {
    print("Removing old website files");
    await for (FileSystemEntity node in new Directory('$websitePath').list()) {
      node.delete(recursive: true);
    }
  }

  Future removeOldBuildFiles() async {
    print("Removing old build files");
    await for (FileSystemEntity node
        in new Directory('$clientPath/build').list()) {
      node.delete(recursive: true);
    }
  }

  deployClient() async {
    await removeOldBuildFiles();
    await buildWebsite();
    await removeOldWebsiteFiles();
    await deployNewSite();
  }
}
