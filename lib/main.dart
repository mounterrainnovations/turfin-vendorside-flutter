import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Controls the active theme mode.
/// To add light theme support later: change this provider's value to
/// ThemeMode.light or ThemeMode.system — everything else updates automatically.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // darkTheme: AppTheme.darkTheme,   // uncomment when lightTheme is ready
      // Swap to: theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppRouter(),
    );
  }
}
