import 'dart:async';

import 'package:test/test.dart';
import '../war_builder.dart';

void main() {
  WarBuilder builder;
  setUp(() {
    builder = new WarBuilder();
  });

  test('should output a war file containing web-inf', () {
    builder.build('/home/joel/code/dart/pokerplanning-webhooks/test/base-war-archive');
  });
}