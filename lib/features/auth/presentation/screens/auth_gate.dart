import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../../services/local_task_storage.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import '../../../tasks/presentation/screens/home_screen.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasCachedTasks = false;
  bool _cacheChecked = false;
  String? _lastCheckedUid;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user != null && auth.user!.uid != _lastCheckedUid) {
      _lastCheckedUid = auth.user!.uid;
      _cacheChecked = false;
      _checkCache(auth.user!.uid);
    }

    switch (auth.status) {
      case AuthStatus.initial:
        if (_cacheChecked && _hasCachedTasks && auth.user != null) {
          _ensureListening(context, auth.user!.uid);
          return const HomeScreen();
        }
        return const SplashScreen();

      case AuthStatus.authenticated:
        _ensureListening(context, auth.user!.uid);
        return const HomeScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.loading:
        return const LoginScreen();
    }
  }

  Future<void> _checkCache(String uid) async {
    final cached = await LocalTaskStorage.load(uid);
    if (mounted) {
      setState(() {
        _hasCachedTasks = cached.isNotEmpty;
        _cacheChecked = true;
      });
    }
  }

  void _ensureListening(BuildContext context, String uid) {
    final taskProv = context.read<TaskProvider>();
    if (taskProv.status == TaskStatus.initial) {
      taskProv.startListening(uid);
    }
  }
}
