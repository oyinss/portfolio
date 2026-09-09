library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api/auth_service.dart';
import '../core/api/portfolio_repository.dart';
import '../core/theme/accent_theme.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router.dart';

class PortfolioApp extends StatefulWidget {
  final ThemeController controller;
  final AuthService auth;
  const PortfolioApp({super.key, required this.controller, required this.auth});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final GoRouter _router;
  late final _repository = PortfolioRepository();

  @override
  void initState() {
    super.initState();
    _router = buildRouter(auth: widget.auth);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      notifier: widget.controller,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final seed = widget.controller.accent.seed;
          return MaterialApp.router(
            title: 'Portfolio',
            theme: buildLightTheme(seed),
            darkTheme: buildDarkTheme(seed),
            themeMode: widget.controller.mode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) => AuthScope(
              auth: widget.auth,
              child: PortfolioScope(repository: _repository, child: child!),
            ),
          );
        },
      ),
    );
  }
}
