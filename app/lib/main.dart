library;

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  final boot = await bootstrap();
  runApp(PortfolioApp(controller: boot.theme, auth: boot.auth));
}
