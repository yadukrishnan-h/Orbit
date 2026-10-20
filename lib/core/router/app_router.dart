import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/features/connect/presentation/screens/add_server_screen.dart';
import 'package:orbit/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:orbit/features/files/presentation/screens/files_screen.dart';
import 'package:orbit/features/home/screens/home_screen.dart';
import 'package:orbit/features/terminal/presentation/screens/terminal_screen.dart';
import 'package:orbit/features/server_details/presentation/screens/server_details_screen.dart';
import 'package:orbit/features/settings/presentation/screens/settings_screen.dart';
import 'package:orbit/features/settings/presentation/screens/manage_servers_screen.dart';
import 'package:orbit/features/settings/presentation/screens/change_pin_screen.dart';
import 'package:orbit/features/settings/presentation/screens/about_screen.dart';
import 'package:orbit/features/settings/presentation/screens/licenses_screen.dart';
import 'package:orbit/features/settings/presentation/screens/legal_document_screen.dart';
import 'package:orbit/core/models/server.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final mediaQuery = MediaQuery.of(context);
        final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
        final systemBottom = mediaQuery.padding.bottom;
        final bottomMargin = systemBottom == 0 ? 16.0 : systemBottom;
        final navBarHeight = 64.0 + bottomMargin;
        final navBarClearance = isKeyboardOpen
            ? systemBottom
            : (navBarHeight + 16.0);

        return Scaffold(
          extendBody: true,
          backgroundColor:
              Colors.transparent, // Let underlying screens show background
          body: MediaQuery(
            data: mediaQuery.copyWith(
              padding: mediaQuery.padding.copyWith(bottom: navBarClearance),
              viewPadding: mediaQuery.viewPadding.copyWith(
                bottom: navBarClearance,
              ),
            ),
            child: child,
          ),
          bottomNavigationBar: isKeyboardOpen
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0A0A0C,
                            ).withValues(alpha: 0.75),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.5,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildNavItem(
                                context,
                                0,
                                LucideIcons.home,
                                'Dashboard',
                                _calculateSelectedIndex(context),
                              ),
                              _buildNavItem(
                                context,
                                1,
                                LucideIcons.terminal,
                                'Terminal',
                                _calculateSelectedIndex(context),
                              ),
                              _buildNavItem(
                                context,
                                2,
                                LucideIcons.folder,
                                'Files',
                                _calculateSelectedIndex(context),
                              ),
                              _buildNavItem(
                                context,
                                3,
                                LucideIcons.settings,
                                'Settings',
                                _calculateSelectedIndex(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/dashboard/:serverId',
          builder: (context, state) {
            final serverId = state.pathParameters['serverId']!;
            return DashboardScreen(serverId: serverId);
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
      ],
    ),
    // ── Modal sub-screens outside ShellRoute so bottom navigation bar does NOT overlay them [UI-005] ──
    GoRoute(
      path: '/add-server',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final existingServer = state.extra is Server
            ? state.extra as Server
            : null;
        return AddServerScreen(existingServer: existingServer);
      },
    ),
    GoRoute(
      path: '/server-details',
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) {
        if (state.extra is! Server) {
          return '/';
        }
        return null;
      },
      builder: (context, state) {
        final server = state.extra as Server;
        return ServerDetailsScreen(server: server);
      },
    ),
    GoRoute(
      path: '/change-pin',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ChangePinScreen(),
    ),
    GoRoute(
      path: '/manage-servers',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ManageServersScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/licenses',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LicensesScreen(),
    ),
    GoRoute(
      path: '/legal',
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) {
        if (state.extra is! Map<String, dynamic>) {
          return '/';
        }
        final args = state.extra as Map<String, dynamic>;
        if (args['title'] is! String || args['assetPath'] is! String) {
          return '/';
        }
        return null;
      },
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return LegalDocumentScreen(
          title: args['title'] as String,
          assetPath: args['assetPath'] as String,
        );
      },
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

Widget _buildNavItem(
  BuildContext context,
  int index,
  IconData icon,
  String label,
  int selectedIndex,
) {
  final isSelected = selectedIndex == index;
  final color = isSelected ? const Color(0xFF00E676) : const Color(0xFFA1A1AA);

  return Expanded(
    child: InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
