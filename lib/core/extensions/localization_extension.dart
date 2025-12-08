import 'package:flutter/cupertino.dart';
import 'package:tasktime/l10n/app_localizations.dart';
extension LocalizationExtension on BuildContext {
  AppLocalizations get  localization => AppLocalizations.of(this)!;
}


