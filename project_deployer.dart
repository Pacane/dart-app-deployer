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

  Future gitPull() async {
    print("Pulling changes");

    ProcessResult result = await Process.run("git", ['pull'], workingDirectory: gitWorkingDir, runInShell: true);
    showLogsForProcessResult(result);
  }

  Future gitReset() async {
    print("Resetting branch");
    ProcessResult result =
        await Process.run("git", ['reset', '--hard', 'origin/$gitTarget'], workingDirectory: gitWorkingDir);
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
    ProcessResult result = await Process.run("pub", ['build', '--mode=release'], workingDirectory: clientPath);
    showLogsForProcessResult(result);
  }

  void killServerProcess() {
    if (serverProcess != null) {
      print("Killing server");
      serverProcess.kill();
    }
  }

  Future upgradeServerDependencies() async {
    ProcessResult result = await Process.run("pub", ['upgrade'], workingDirectory: serverPath);
    showLogsForProcessResult(result);
  }

  Future startServer() async {
    killServerProcess();

    print("Starting server");
    Process result = await Process.start("dart", ['$serverFileName'], workingDirectory: serverPath);
    serverProcess = result;
    showLogs(result);
  }

  Future deployNewSite() async {
    print("Deploying new site");
    ProcessResult result = await Process.run("cp", ['$clientPath/build/web/*', '$websitePath', '-r']);
    showLogsForProcessResult(result);
  }

  Future removeOldWebsiteFiles() async {
    print("Removing old website files");
    ProcessResult result = await Process.run("rm", ['-rf', '$websitePath/*']);
    showLogsForProcessResult(result);
  }

  Future removeOldBuildFiles() async {
    print("Removing old build files");
    ProcessResult result = await Process.run("rm", ['-rf', '$clientPath/build/*']);
    showLogsForProcessResult(result);
  }

  deployClient() async {
    await removeOldBuildFiles();
    await buildWebsite();
    await removeOldWebsiteFiles();
    await deployNewSite();
  }
}
