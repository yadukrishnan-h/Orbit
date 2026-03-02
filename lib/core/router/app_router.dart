import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/features/connect/presentation/screens/add_server_screen.dart';
import 'package:orbit/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:orbit/features/files/presentation/screens/files_screen.dart';
import 'package:orbit/features/home/screens/home_screen.dart';
import 'package:orbit/features/terminal/presentation/screens/terminal_screen.dart';
import 'package:orbit/features/server_details/presentation/screens/server_details_screen.dart';
import 'package:orbit/features/settings/presentation/screens/settings_screen.dart';
import 'package:orbit/features/settings/presentation/screens/manage_servers_screen.dart';
import 'package:orbit/core/models/server.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.terminal),
                label: 'Terminal',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.folder),
                label: 'Files',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.settings),
                label: 'Settings',
              ),
            ],
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/dashboard/:serverId',
          builder: (context, state) {
            final serverId = state.pathParameters['serverId']!;
            return DashboardScreen(
              serverId: serverId,
            );
          },
        ),
        GoRoute(
          path: '/add-server',
          builder: (context, state) {
            final existingServer = state.extra as Server?;
            return AddServerScreen(existingServer: existingServer);
          },
        ),
        GoRoute(
          path: '/server-details',
          builder: (context, state) {
            final server = state.extra as Server;
            return ServerDetailsScreen(server: server);
          },
        ),
        GoRoute(
          path: '/terminal',
          builder: (context, state) => const TerminalScreen(),
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) => const FilesScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/manage-servers',
          builder: (context, state) => const ManageServersScreen(),
        ),
      ],
    ),
  ],
);

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/terminal')) {
    return 1;
  }
  if (location.startsWith('/files')) {
    return 2;
  }
  if (location.startsWith('/settings')) {
    return 3;
  }
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      GoRouter.of(context).go('/');
      break;
    case 1:
      GoRouter.of(context).go('/terminal');
      break;
    case 2:
      GoRouter.of(context).go('/files');
      break;
    case 3:
      GoRouter.of(context).go('/settings');
      break;
  }
}
