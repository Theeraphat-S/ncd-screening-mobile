import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'home_page_localizations_en.dart';
import 'home_page_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of HomePageLocalizations
/// returned by `HomePageLocalizations.of(context)`.
///
/// Applications need to include `HomePageLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'home_page/home_page_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: HomePageLocalizations.localizationsDelegates,
///   supportedLocales: HomePageLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the HomePageLocalizations.supportedLocales
/// property.
abstract class HomePageLocalizations {
  HomePageLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HomePageLocalizations? of(BuildContext context) {
    return Localizations.of<HomePageLocalizations>(
      context,
      HomePageLocalizations,
    );
  }

  static const LocalizationsDelegate<HomePageLocalizations> delegate =
      _HomePageLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// Welcome to {appName}
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String text_welcome(Object appName);

  /// Check IP
  ///
  /// In en, this message translates to:
  /// **'Check IP'**
  String get btn_check_ip;

  /// IP: {ip}
  ///
  /// In en, this message translates to:
  /// **'IP: {ip}'**
  String text_ip(Object ip);
}

class _HomePageLocalizationsDelegate
    extends LocalizationsDelegate<HomePageLocalizations> {
  const _HomePageLocalizationsDelegate();

  @override
  Future<HomePageLocalizations> load(Locale locale) {
    return SynchronousFuture<HomePageLocalizations>(
      lookupHomePageLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_HomePageLocalizationsDelegate old) => false;
}

HomePageLocalizations lookupHomePageLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return HomePageLocalizationsEn();
    case 'th':
      return HomePageLocalizationsTh();
  }

  throw FlutterError(
    'HomePageLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
