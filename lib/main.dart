import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/core/theme.dart';

import 'features/auth/presentation/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: LogsApp()));
}

class LogsApp extends ConsumerWidget {
  const LogsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Logs',
      debugShowCheckedModeBanner: false,
      theme: buildBWTheme(themeState.font),
      home: const SplashPage(),
    );
  }
}
