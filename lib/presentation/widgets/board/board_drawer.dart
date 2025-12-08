import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasktime/core/extensions/localization_extension.dart';
import '../../../core/router/app_routes.dart';
import '../../../domain/entities/project_entity.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../cubits/language/language_cubit.dart';

/// Drawer for the board page
class BoardDrawer extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onChangeProject;

  const BoardDrawer({
    super.key,
    required this.project,
    required this.onChangeProject,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildHistoryTile(context),
          const Divider(),
          _buildThemeSection(context),
          const Divider(),
          _buildLanguageSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.timer, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onChangeProject,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.settings, color: Colors.white),
              ],
            ),
          ),
          Text(
            context.localization.taskTracker,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title:  Text(context.localization.history),
      subtitle:  Text(context.localization.viewCompletedTasks),
      onTap: () {
        context.pop(); // Close drawer
        context.push(AppRoutes.history);
      },
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context.localization.theme),
            _buildThemeTile(context, context.localization.system,
                Icons.brightness_auto, ThemeMode.system, state.mode),
            _buildThemeTile(context, context.localization.light,
                Icons.light_mode, ThemeMode.light, state.mode),
            _buildThemeTile(context, context.localization.dark, Icons.dark_mode,
                ThemeMode.dark, state.mode),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () => context.read<ThemeCubit>().setThemeMode(mode),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final cubit = context.read<LanguageCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Language'),
            ...cubit.supportedLocales.map((locale) => _buildLanguageTile(
                  context,
                  cubit.getFlag(locale),
                  cubit.getLanguageName(locale),
                  locale,
                  state.locale,
                )),
          ],
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String flag,
    String name,
    Locale locale,
    Locale currentLocale,
  ) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        context.read<LanguageCubit>().setLanguage(locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $name'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
