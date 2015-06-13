@TestOn('vm')
import 'package:test/test.dart';
import '../project_deployer.dart';

main() {
  ProjectDeployer deployer = new ProjectDeployer({});

  deployer.clientPath = 'test/srcDirectory';
  deployer.websitePath = 'test/destDirectory';

  test('copying files', () {
    deployer.deployNewSite();
  });
}
