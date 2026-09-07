import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import '../../../tasks/presentation/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    switch (authStatus) {
      case AuthStatus.initial:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.loading:
        return const LoginScreen();
    }
  }
}
