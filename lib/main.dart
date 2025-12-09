import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tasktime/l10n/app_localizations.dart';
import 'package:tasktime/presentation/cubits/sync/sync_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'di/injection.dart';
import 'di/api_injection.dart' as api_di;
import 'data/providers/secure_storage_provider.dart';
import 'presentation/cubits/theme/theme_cubit.dart';
import 'presentation/cubits/language/language_cubit.dart';
import 'presentation/cubits/project/project_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await _initializeDefaultToken();
  runApp(const TaskTimeApp());
}

/// Initialize default Todoist token if configured
Future<void> _initializeDefaultToken() async {
  if (AppConfig.hasDefaultToken) {
    final secureStorage = getIt<SecureStorageProvider>();
    final hasToken = await secureStorage.hasTodoistToken();
    if (!hasToken) {
      await secureStorage.saveTodoistToken(AppConfig.defaultTodoistToken);
      api_di.initializeApiProviders(AppConfig.defaultTodoistToken);
    }
  }
}

/// Main application widget
class TaskTimeApp extends StatelessWidget {
  const TaskTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(
          create: (_) => ProjectCubit(
            secureStorage: getIt<SecureStorageProvider>(),
          ),
        ),BlocProvider(
          create: (_) => getIt<SyncCubit>()
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return MaterialApp.router(
                title: 'TaskTime',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.mode,
                locale: langState.locale,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  AppLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('de'),
                ],
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
