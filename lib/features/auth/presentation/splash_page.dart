// lib/features/auth/presentation/splash_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logs_mobile_app/features/auth/state/auth_controller.dart';
import 'package:logs_mobile_app/features/home/presentation/home_page.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _delayElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Start the 1s splash delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _delayElapsed = true);

      // After delay, route once with the current state
      _maybeRoute(ref.read(authControllerProvider));
    });
  }

  void _maybeRoute(AuthState state) {
    if (!mounted || _navigated == true || _delayElapsed == false) return;

    if (state is Authenticated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: state.user)),
      );
    } else if (state is AuthNeedsEmailVerification) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(initialEmail: state.email),
        ),
      );
    } else if (state is Unauthenticated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
    // AuthUnknown/AuthLoading -> remain until a new state arrives.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // Listen INSIDE build (allowed). Route only after delay & not yet navigated.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      _maybeRoute(next);
    });

    // If delay already elapsed, ensure we try routing at least once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRoute(state);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
