import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/weather/presentation/home_widget.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const GoSail();
      }
    ),
  ],
);