import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_env.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Controls the active theme mode.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// A single navigator key shared between MaterialApp and Alice so the
// inspector overlay can push itself onto the navigation stack.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire Alice before the first frame so it can catch calls made during init.
  // In production builds AppEnv.showInspector is false, so this is a no-op
  // and the Alice package is fully tree-shaken from the binary.
  DioClient.initAlice(navigatorKey); // no-op in production builds

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: TurfinVendorApp()));
}

class TurfinVendorApp extends ConsumerWidget {
  const TurfinVendorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TurfIn Vendor',
      debugShowCheckedModeBanner: !AppEnv.isProduction,
      navigatorKey: navigatorKey, // required for Alice inspector overlay
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppRouter(),
    );
  }
}
