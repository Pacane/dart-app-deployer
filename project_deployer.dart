import 'dart:io';
import 'dart:convert' show UTF8;
import 'dart:async';

class ProjectDeployer {
  void deployNewSite() async {
    Process copyProcess = await Process.start("bash", ["-c", "cp $clientPath/build/web/* $websitePath -r"]);
    showLogs(copyProcess);
  }

  void removeOldWebsiteFiles() async {
    print("Removing old website files");

    Process cleaningProcess = await Process.start("bash", ["-c", "rm -rf $websitePath/* -r"]);
    showLogs(cleaningProcess);
  }

  void deployClient() {
    buildWebsite();
    removeOldWebsiteFiles();
    deployNewSite();
  }

  Map config;
  var clientPath;
  var gitTarget;
  var gitWorkingDir;
  var serverFileName;
  var serverPath;
  var websitePath;
  Process serverProcess;

  ProjectDeployer(this.config) {
    print("In project deployer");
    clientPath = config["clientPath"];
    gitTarget = config["gitTarget"];
    gitWorkingDir = config["gitWorkingDir"];
    serverFileName = config["serverFileName"];
    serverPath = config["serverPath"];
    websitePath = config["websitePath"];
  }

  void resetAndPullBranch() {
    print("Resetting branch");
    Process.start("bash", ["-c", "git pull && git reset --hard $gitTarget"], workingDirectory: gitWorkingDir)
    .then((process) => showLogs(process));
  }

  void showLogs(Process process) {
    process.stdout.transform(UTF8.decoder).listen((data) => print(data));
    process.stderr.transform(UTF8.decoder).listen((data) => print(data));
  }

  void buildWebsite() {
    Process.start("bash", ["-c", "pub build"], workingDirectory : clientPath).then((process) => showLogs(process));
  }

  void killServerProcess() {
    if (serverProcess != null) {
      print("Killing server");
      serverProcess.kill();
    }
  }

  void startServer() {
    killServerProcess();

    print("Starting server");
    Process.start("bash", ["-c", "dart $serverFileName"], workingDirectory : serverPath).then((Process process) {
      serverProcess = process;
      showLogs(process);
    });
  }
}