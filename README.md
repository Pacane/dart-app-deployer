Dart app deployer
=============
#Getting Started
This program is meant to deploy your Dart app to your production server. To do so, it listens to GitHub Webhooks for push on a specified branch. Run this on your production server.

##Requirements
To use this project as it is right now, you have to :
* have a Dart frontend
* have a Dart backend
* use git and GitHub
* have a production webserver serving your files

##Setup
* Create a config file named `config.yaml` in the root of the project. This file will have to contain the following entries
(replace the values with your actual configuration, this is an example configuration)

```yaml
listeningPort: portThatTheDaemonWillListenOnto (ie: 3000)
gitWorkingDir: /path/to/the/git/directory/of/your/project
clientPath: /path/to/the/client/directory
websitePath: /path/of/deployment
serverPath: /path/to/the/server/directory
serverFileName: main.dart
gitTarget: origin/master
```
* Create a [Webhook](https://developer.github.com/webhooks/creating/) in your github repository that sends you push information.
* Create an environment variable named `GITHUB_TOKEN` on the production server that has the value of the secret token of your GitHub hook.

##Running it
On the production server, checkout this project and run `dart -c --enable-async hook.dart`. A daemon will:

* listen to GitHub `POST` requests
* see if it matches GitHub's signature
* check if it's a push on the correct branch
* if everything matches, remove old website files, and deploy the new ones.
