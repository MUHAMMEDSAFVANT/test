import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/tasks/data/repositories/firestore_task_repository.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();
  runApp(const TaskNestApp());
}

class TaskNestApp extends StatelessWidget {
  const TaskNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: FirebaseAuthRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: FirestoreTaskRepository(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp(
                title: 'MyApp',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light.copyWith(
                  textTheme: GoogleFonts.poppinsTextTheme(
                    AppTheme.light.textTheme,
                  ),
                ),
                darkTheme: AppTheme.dark.copyWith(
                  textTheme: GoogleFonts.poppinsTextTheme(
                    AppTheme.dark.textTheme,
                  ),
                ),
                themeMode: themeProvider.themeMode,
                home: const AuthGate(),
              );
            },
          );
        },
      ),
    );
  }
}
