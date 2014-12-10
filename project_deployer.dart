import 'dart:io';
import 'dart:convert' show UTF8;
import 'dart:async';

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
    print("In project deployer");
    clientPath = config["clientPath"];
    gitTarget = config["gitTarget"];
    gitWorkingDir = config["gitWorkingDir"];
    serverFileName = config["serverFileName"];
    serverPath = config["serverPath"];
    websitePath = config["websitePath"];
  }

  Future resetAndPullBranch() {
    print("Resetting branch");
    return Process.run("bash", ["-c", "git pull && git reset --hard $gitTarget"], workingDirectory: gitWorkingDir)
    .then((process) => showLogsForProcessResult(process));
  }

  void showLogs(Process process) {
    process.stdout.transform(UTF8.decoder).listen((data) => print(data));
    process.stderr.transform(UTF8.decoder).listen((data) => print(data));
  }

  void showLogsForProcessResult(ProcessResult processResult) {
    print(processResult.stderr);
    print(processResult.stdout);
  }

  Future buildWebsite() {
    print("Building website");
    return Process.run("bash", ["-c", "pub build"], workingDirectory : clientPath).then((process) => showLogsForProcessResult(process));
  }

  void killServerProcess() {
    if (serverProcess != null) {
      print("Killing server");
      serverProcess.kill();
    }
  }

  Future startServer() {
    killServerProcess();

    print("Starting server");
    return Process.start("bash", ["-c", "dart $serverFileName"], workingDirectory : serverPath).then((Process process) {
      serverProcess = process;
      showLogs(process);
    });
  }

  Future deployNewSite() {
    print("Deploying new site");
    return Process.run("bash", ["-c", "cp $clientPath/build/web/* $websitePath -r"]).then((process) => showLogsForProcessResult(process));
  }

  Future removeOldWebsiteFiles() {
    print("Removing old website files");
    return Process.run("bash", ["-c", "rm -rf $websitePath/* -r"]).then((process) => showLogsForProcessResult(process));
  }

  deployClient() async {
    await buildWebsite();
    await removeOldWebsiteFiles();
    await deployNewSite();
  }
}