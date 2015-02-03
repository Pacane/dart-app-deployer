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
    clientPath = config["clientPath"];
    gitTarget = config["gitTarget"];
    gitWorkingDir = config["gitWorkingDir"];
    serverFileName = config["serverFileName"];
    serverPath = config["serverPath"];
    websitePath = config["websitePath"];
  }

  Future gitPull() {
    print("Pulling changes");
    return Process.run("git", ['pull'], workingDirectory: gitWorkingDir, runInShell: true)
    .then((process) => showLogsForProcessResult(process));
  }

  Future gitReset() {
    print("Resetting branch");
    return Process.run("git", ['reset', '--hard', 'origin/$gitTarget'], workingDirectory: gitWorkingDir, runInShell: true)
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
    return Process.run("pub", ['build', '--mode=release'], workingDirectory : clientPath, runInShell: true).then((process){
      showLogsForProcessResult(process);
      print(process.exitCode);
    });
  }

  void killServerProcess() {
    if (serverProcess != null) {
      print("Killing server");
      serverProcess.kill();
    }
  }

  Future upgradeServerDependencies() {
    return Process.run("pub", ['upgrade'], workingDirectory: serverPath).then((process) => showLogsForProcessResult(process));
  }

  Future startServer() {
    killServerProcess();

    print("Starting server");
    return Process.start("dart", ['$serverFileName'], workingDirectory : serverPath, runInShell: true).then((Process process) {
      serverProcess = process;
      showLogs(process);
    });
  }

  Future deployNewSite() {
    print("Deploying new site");
    return Process.run("cp", ['$clientPath/build/web/*', '$websitePath', '-r'], runInShell: true).then((process) => showLogsForProcessResult(process));
  }

  Future removeOldWebsiteFiles() {
    print("Removing old website files");
    return Process.run("rm", ['-rf', '$websitePath/*', '-r'], runInShell: true).then((process) => showLogsForProcessResult(process));
  }

  deployClient() async {
    await buildWebsite();
    await removeOldWebsiteFiles();
    await deployNewSite();
  }
}
