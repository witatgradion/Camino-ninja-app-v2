import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
  ];

  ///
  ///
  /// In en, this message translates to:
  /// **'Accommodation address'**
  String get accommodationAddress;

  ///
  ///
  /// In en, this message translates to:
  /// **'Accommodation name'**
  String get accommodationName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Accommodations'**
  String get accommodations;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addStage.
  ///
  /// In en, this message translates to:
  /// **'Add Stage'**
  String get addStage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Additional feedback'**
  String get additionalFeedback;

  ///
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// No description provided for @allCities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get allCities;

  /// No description provided for @allYear.
  ///
  /// In en, this message translates to:
  /// **'All year'**
  String get allYear;

  /// No description provided for @allYearChristmasToMarch6FriSat.
  ///
  /// In en, this message translates to:
  /// **'All year, except from Christmas to March 6 it is open only Friday and Saturday (except for groups of more than 6 people)'**
  String get allYearChristmasToMarch6FriSat;

  /// No description provided for @allYearClosedHolidays.
  ///
  /// In en, this message translates to:
  /// **'All year, but closed for pilgrims for New Year, Epiphany, Easter, July, August and Christmas'**
  String get allYearClosedHolidays;

  /// No description provided for @allYearClosedSatSun_713.
  ///
  /// In en, this message translates to:
  /// **'All year (closed Saturdays and Sundays)'**
  String get allYearClosedSatSun_713;

  /// No description provided for @allYearClosedSundays.
  ///
  /// In en, this message translates to:
  /// **'All year (closed on Sundays)'**
  String get allYearClosedSundays;

  /// No description provided for @allYearClosedThursdays.
  ///
  /// In en, this message translates to:
  /// **'All year, closed on Thursdays'**
  String get allYearClosedThursdays;

  /// No description provided for @allYearClosedTueNovToFebFriSun.
  ///
  /// In en, this message translates to:
  /// **'All year (closed on Tuesdays. November 1 to February 29 only open Friday to Sunday)'**
  String get allYearClosedTueNovToFebFriSun;

  /// No description provided for @allYearClosedTuesFeb2022.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 1, January 15 to Febuary 15 and December 24 to 25 and 30 to 31 (closed on tuesdays until Febuary 2022).'**
  String get allYearClosedTuesFeb2022;

  /// No description provided for @allYearClosedTuesdays.
  ///
  /// In en, this message translates to:
  /// **'All year (Closed on Tuesdays)'**
  String get allYearClosedTuesdays;

  /// No description provided for @allYearClosedTuesdays_544.
  ///
  /// In en, this message translates to:
  /// **'All year (closed on Tuesdays)'**
  String get allYearClosedTuesdays_544;

  /// No description provided for @allYearClosedTuesdays_589.
  ///
  /// In en, this message translates to:
  /// **'All year (closed on Tuesdays)'**
  String get allYearClosedTuesdays_589;

  /// No description provided for @allYearClosedWednesdays_585.
  ///
  /// In en, this message translates to:
  /// **'All year (closed on wednesdays)'**
  String get allYearClosedWednesdays_585;

  /// No description provided for @allYearClosedWeekends.
  ///
  /// In en, this message translates to:
  /// **'All year, closed in weekends'**
  String get allYearClosedWeekends;

  /// No description provided for @allYearDec1ToFeb28Call.
  ///
  /// In en, this message translates to:
  /// **'All year (December 1 to February 28 call in advance)'**
  String get allYearDec1ToFeb28Call;

  /// No description provided for @allYearExcept20DaysJuly.
  ///
  /// In en, this message translates to:
  /// **'All year, except 20 days in July'**
  String get allYearExcept20DaysJuly;

  /// No description provided for @allYearExcept4DaysMidSeptember.
  ///
  /// In en, this message translates to:
  /// **'All year, except for 4 days in mid-September for the festivities (days vary every year)'**
  String get allYearExcept4DaysMidSeptember;

  /// No description provided for @allYearExceptChristmasHolidays.
  ///
  /// In en, this message translates to:
  /// **'All year, except Christmas holydays'**
  String get allYearExceptChristmasHolidays;

  /// No description provided for @allYearExceptChristmasWeek.
  ///
  /// In en, this message translates to:
  /// **'All year, except Christmas week'**
  String get allYearExceptChristmasWeek;

  /// No description provided for @allYearExceptChristmas_190.
  ///
  /// In en, this message translates to:
  /// **'All year, except Christmas'**
  String get allYearExceptChristmas_190;

  /// No description provided for @allYearExceptDec10ToJan1.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 10 to January 1'**
  String get allYearExceptDec10ToJan1;

  /// No description provided for @allYearExceptDec11ToJan9.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 11 to January 9'**
  String get allYearExceptDec11ToJan9;

  /// No description provided for @allYearExceptDec15To30.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 15 to 30'**
  String get allYearExceptDec15To30;

  /// No description provided for @allYearExceptDec15ToJan15TuesWinter.
  ///
  /// In en, this message translates to:
  /// **'January 16 to December 14, except Tuesdays in winter'**
  String get allYearExceptDec15ToJan15TuesWinter;

  /// No description provided for @allYearExceptDec15ToJan1_217.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 15 to January 1'**
  String get allYearExceptDec15ToJan1_217;

  /// No description provided for @allYearExceptDec19ToJan3.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 19 to January 3'**
  String get allYearExceptDec19ToJan3;

  /// No description provided for @allYearExceptDec20ToJan10.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 20 to January 10'**
  String get allYearExceptDec20ToJan10;

  /// No description provided for @allYearExceptDec22To25_619.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 22 to 25'**
  String get allYearExceptDec22To25_619;

  /// No description provided for @allYearExceptDec22To29Jan15ToFeb15.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 22 to 29 and January 15 to February 15'**
  String get allYearExceptDec22To29Jan15ToFeb15;

  /// No description provided for @allYearExceptDec22ToJan8.
  ///
  /// In en, this message translates to:
  /// **'All year, except from December 22 to January 8'**
  String get allYearExceptDec22ToJan8;

  /// No description provided for @allYearExceptDec232425.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 23, 24 and 25'**
  String get allYearExceptDec232425;

  /// No description provided for @allYearExceptDec23ToJan3.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 23 to January 3'**
  String get allYearExceptDec23ToJan3;

  /// No description provided for @allYearExceptDec23ToJan7_459.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 23 to January 7'**
  String get allYearExceptDec23ToJan7_459;

  /// No description provided for @allYearExceptDec23ToJan8_486.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 23 to January 8'**
  String get allYearExceptDec23ToJan8_486;

  /// No description provided for @allYearExceptDec23ToMarch1.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 23 to March 1'**
  String get allYearExceptDec23ToMarch1;

  /// No description provided for @allYearExceptDec242531Jan156.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24, 25 and 31 and January 01, 05 and 06'**
  String get allYearExceptDec242531Jan156;

  /// No description provided for @allYearExceptDec2425_571.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 & 25'**
  String get allYearExceptDec2425_571;

  /// No description provided for @allYearExceptDec24After25Dec31AfterJan1.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 (afternoon), 25, 31 (afternoon) and January 1'**
  String get allYearExceptDec24After25Dec31AfterJan1;

  /// No description provided for @allYearExceptDec24And25.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 and 25'**
  String get allYearExceptDec24And25;

  /// No description provided for @allYearExceptDec24And25_490.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 and 25'**
  String get allYearExceptDec24And25_490;

  /// No description provided for @allYearExceptDec24And25_653.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 and 25'**
  String get allYearExceptDec24And25_653;

  /// No description provided for @allYearExceptDec24To31.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 to 31'**
  String get allYearExceptDec24To31;

  /// No description provided for @allYearExceptDec24To31Jan6.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 to 31 and January 6'**
  String get allYearExceptDec24To31Jan6;

  /// No description provided for @allYearExceptDec24ToJan10_661.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 to January 10'**
  String get allYearExceptDec24ToJan10_661;

  /// No description provided for @allYearExceptDec24ToJan7.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24 to January 7'**
  String get allYearExceptDec24ToJan7;

  /// No description provided for @allYearExceptDec25Jan1.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 25 and January 1'**
  String get allYearExceptDec25Jan1;

  /// No description provided for @allYearExceptDec30ToJan2.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 30 to January 2'**
  String get allYearExceptDec30ToJan2;

  /// No description provided for @allYearExceptDec31.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 31'**
  String get allYearExceptDec31;

  /// No description provided for @allYearExceptDec8To26.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 8 to 26'**
  String get allYearExceptDec8To26;

  /// No description provided for @allYearExceptDecHolidaysJan1.
  ///
  /// In en, this message translates to:
  /// **'All year, except December 24, 25, 31 and January 1'**
  String get allYearExceptDecHolidaysJan1;

  /// No description provided for @allYearExceptDecember.
  ///
  /// In en, this message translates to:
  /// **'All year, except December'**
  String get allYearExceptDecember;

  /// No description provided for @allYearExceptFeb8To28_479.
  ///
  /// In en, this message translates to:
  /// **'All year, except February 8 to 28'**
  String get allYearExceptFeb8To28_479;

  /// No description provided for @allYearExceptFebChristmas.
  ///
  /// In en, this message translates to:
  /// **'All year, except February and Christmas'**
  String get allYearExceptFebChristmas;

  /// No description provided for @allYearExceptFebClosedMondays.
  ///
  /// In en, this message translates to:
  /// **'All year, except February (closed on Mondays in January, March, November and December)'**
  String get allYearExceptFebClosedMondays;

  /// No description provided for @allYearExceptFebClosedWed.
  ///
  /// In en, this message translates to:
  /// **'All year, except February (closed on Wednesdays in winter)'**
  String get allYearExceptFebClosedWed;

  /// No description provided for @allYearExceptFebClosedWednesdays.
  ///
  /// In en, this message translates to:
  /// **'All year, except February (closed on Wednesdays)'**
  String get allYearExceptFebClosedWednesdays;

  /// No description provided for @allYearExceptFebruary.
  ///
  /// In en, this message translates to:
  /// **'All year, except February'**
  String get allYearExceptFebruary;

  /// No description provided for @allYearExceptHolidaysJanuary.
  ///
  /// In en, this message translates to:
  /// **'All year (except Christmas holidays and January)'**
  String get allYearExceptHolidaysJanuary;

  /// No description provided for @allYearExceptJan10ToMarch1_587.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 10 to March 1'**
  String get allYearExceptJan10ToMarch1_587;

  /// No description provided for @allYearExceptJan10ToMarch31.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 10 to March 31'**
  String get allYearExceptJan10ToMarch31;

  /// No description provided for @allYearExceptJan12April17Dec24To26.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 1 to 2, April 17 (2022) and December 24 to 26'**
  String get allYearExceptJan12April17Dec24To26;

  /// No description provided for @allYearExceptJan15To31.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 15 to 31'**
  String get allYearExceptJan15To31;

  /// No description provided for @allYearExceptJan15ToFeb15_218.
  ///
  /// In en, this message translates to:
  /// **'All year, except from January 15 to February 15'**
  String get allYearExceptJan15ToFeb15_218;

  /// No description provided for @allYearExceptJan15ToFeb28_677.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 15 to February 28'**
  String get allYearExceptJan15ToFeb28_677;

  /// No description provided for @allYearExceptJan18Feb18Dec242531.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 1, January 18 to February 18 and December 24, 25 & 31'**
  String get allYearExceptJan18Feb18Dec242531;

  /// No description provided for @allYearExceptJan1ToFeb28.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 1 to February 28'**
  String get allYearExceptJan1ToFeb28;

  /// No description provided for @allYearExceptJan56Dec242531.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 1, 5 & 6 and December 24, 25 & 31'**
  String get allYearExceptJan56Dec242531;

  /// No description provided for @allYearExceptJan6ToFeb28_481.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 6 to February 28'**
  String get allYearExceptJan6ToFeb28_481;

  /// No description provided for @allYearExceptJan8ToFeb8.
  ///
  /// In en, this message translates to:
  /// **'All year, except January 8 to February 8'**
  String get allYearExceptJan8ToFeb8;

  /// No description provided for @allYearExceptJanFebNov.
  ///
  /// In en, this message translates to:
  /// **'All year, except January, February and November'**
  String get allYearExceptJanFebNov;

  /// No description provided for @allYearExceptJanuary_540.
  ///
  /// In en, this message translates to:
  /// **'All year, except January'**
  String get allYearExceptJanuary_540;

  /// No description provided for @allYearExceptJuly1ToAug31.
  ///
  /// In en, this message translates to:
  /// **'All year, except July 1 to August 31'**
  String get allYearExceptJuly1ToAug31;

  /// No description provided for @allYearExceptJuly5To15.
  ///
  /// In en, this message translates to:
  /// **'All year, except July 5 to 15'**
  String get allYearExceptJuly5To15;

  /// No description provided for @allYearExceptJuly6To14.
  ///
  /// In en, this message translates to:
  /// **'All year, except July 6 to 14'**
  String get allYearExceptJuly6To14;

  /// No description provided for @allYearExceptLast3WeeksJan.
  ///
  /// In en, this message translates to:
  /// **'All year, except the last 3 weeks in January'**
  String get allYearExceptLast3WeeksJan;

  /// No description provided for @allYearExceptLastTwoWeeksDecember.
  ///
  /// In en, this message translates to:
  /// **'All year, except the last two weeks in December'**
  String get allYearExceptLastTwoWeeksDecember;

  /// No description provided for @allYearExceptNov15To30.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 15 to 30'**
  String get allYearExceptNov15To30;

  /// No description provided for @allYearExceptNov15ToDec20.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 15 to December 20'**
  String get allYearExceptNov15ToDec20;

  /// No description provided for @allYearExceptNov1To11Dec14ToJan2.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 1 to 11 and December 14 to January 2'**
  String get allYearExceptNov1To11Dec14ToJan2;

  /// No description provided for @allYearExceptNov1To22.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 1 to 22'**
  String get allYearExceptNov1To22;

  /// No description provided for @allYearExceptNov1To30.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 1 to 30'**
  String get allYearExceptNov1To30;

  /// No description provided for @allYearExceptNov1To7_584.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 1 to 7'**
  String get allYearExceptNov1To7_584;

  /// No description provided for @allYearExceptNov1To7_625.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 1 to 7'**
  String get allYearExceptNov1To7_625;

  /// No description provided for @allYearExceptNov25ToDec29.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 25 to December 29'**
  String get allYearExceptNov25ToDec29;

  /// No description provided for @allYearExceptNov29Dec12Dec2425Dec31Jan1.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 29 to December 12, December 24 to 25 and December 31 to January 1'**
  String get allYearExceptNov29Dec12Dec2425Dec31Jan1;

  /// No description provided for @allYearExceptNov5ToJan25.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 5 to January 25'**
  String get allYearExceptNov5ToJan25;

  /// No description provided for @allYearExceptNov6To20Dec20To29.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 6 to 20 and December 20 to 29'**
  String get allYearExceptNov6To20Dec20To29;

  /// No description provided for @allYearExceptNov7To30.
  ///
  /// In en, this message translates to:
  /// **'All year, except November 7 to 30'**
  String get allYearExceptNov7To30;

  /// No description provided for @allYearExceptSomeDaysAugust.
  ///
  /// In en, this message translates to:
  /// **'All year, except some days in August'**
  String get allYearExceptSomeDaysAugust;

  /// No description provided for @allYearExceptSomeDaysChristmas.
  ///
  /// In en, this message translates to:
  /// **'All year, except some days for Christmas'**
  String get allYearExceptSomeDaysChristmas;

  /// No description provided for @allYearExceptSomeDaysWinter.
  ///
  /// In en, this message translates to:
  /// **'All year, except some days in winter'**
  String get allYearExceptSomeDaysWinter;

  /// No description provided for @allYearJan1To31Confirm.
  ///
  /// In en, this message translates to:
  /// **'All year, January 1 to 31 confirm'**
  String get allYearJan1To31Confirm;

  /// No description provided for @allYearLowSeasonConfirm.
  ///
  /// In en, this message translates to:
  /// **'All year, in low season confirm'**
  String get allYearLowSeasonConfirm;

  /// No description provided for @allYearLowSeasonReservation.
  ///
  /// In en, this message translates to:
  /// **'All year, in low season by reservation'**
  String get allYearLowSeasonReservation;

  /// No description provided for @allYearMayCloseWinter.
  ///
  /// In en, this message translates to:
  /// **'All year (may be closed in winter depending on demand)'**
  String get allYearMayCloseWinter;

  /// No description provided for @allYearNotify15Days.
  ///
  /// In en, this message translates to:
  /// **'All year round (from November 1 to March 31, notify 15 days in advance)'**
  String get allYearNotify15Days;

  /// No description provided for @allYearNov15ToFeb15Reservation.
  ///
  /// In en, this message translates to:
  /// **'All year (by reservation only between November 15 and February 15)'**
  String get allYearNov15ToFeb15Reservation;

  /// No description provided for @allYearNov15ToMarch15Confirm.
  ///
  /// In en, this message translates to:
  /// **'All year, from November 15 to March 15 confirm'**
  String get allYearNov15ToMarch15Confirm;

  /// No description provided for @allYearNov1ToFeb28Reservation.
  ///
  /// In en, this message translates to:
  /// **'All year, but only by reservation from November 1 to February 28'**
  String get allYearNov1ToFeb28Reservation;

  /// No description provided for @allYearNov1ToFeb28Reservation_220.
  ///
  /// In en, this message translates to:
  /// **'All year, November 1 to February 28 only with reservation'**
  String get allYearNov1ToFeb28Reservation_220;

  /// No description provided for @allYearNov1ToJan31MayClose.
  ///
  /// In en, this message translates to:
  /// **'All year, but can be closed from November 1 to January 31'**
  String get allYearNov1ToJan31MayClose;

  /// No description provided for @allYearNov1ToMarch31Confirm.
  ///
  /// In en, this message translates to:
  /// **'All year (November 1 to March 31 confirm)'**
  String get allYearNov1ToMarch31Confirm;

  /// No description provided for @allYearNovToMarchFriSat.
  ///
  /// In en, this message translates to:
  /// **'All year (from end of November to March 11 only open Fridays and Saturdays)'**
  String get allYearNovToMarchFriSat;

  /// No description provided for @allYearOct15ToMarch15Call.
  ///
  /// In en, this message translates to:
  /// **'All year, October 15 to March 15, call first'**
  String get allYearOct15ToMarch15Call;

  /// No description provided for @allYearOctToMarchGroups.
  ///
  /// In en, this message translates to:
  /// **'All year (October 31 to March 1 only for groups with reservation)'**
  String get allYearOctToMarchGroups;

  /// No description provided for @allYearSomeDaysClosed.
  ///
  /// In en, this message translates to:
  /// **'All year, but some days the hostel is closed.'**
  String get allYearSomeDaysClosed;

  /// No description provided for @allYearWinterConfirm.
  ///
  /// In en, this message translates to:
  /// **'All year, in winter confirm'**
  String get allYearWinterConfirm;

  /// No description provided for @allYearWinterGroupsReservation.
  ///
  /// In en, this message translates to:
  /// **'All year (in winter only for groups with reservation)'**
  String get allYearWinterGroupsReservation;

  /// No description provided for @allYearWinterNotify.
  ///
  /// In en, this message translates to:
  /// **'All year, in winter notify your arrival'**
  String get allYearWinterNotify;

  /// No description provided for @allYearWinterReserve.
  ///
  /// In en, this message translates to:
  /// **'All year, in winter make reservation'**
  String get allYearWinterReserve;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @allowsPets.
  ///
  /// In en, this message translates to:
  /// **'Allows Pets'**
  String get allowsPets;

  ///
  ///
  /// In en, this message translates to:
  /// **'And more'**
  String get andMore;

  /// No description provided for @announcementDetail.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcementDetail;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @albergueReviewRequestTopic.
  ///
  /// In en, this message translates to:
  /// **'Albergue review requests'**
  String get albergueReviewRequestTopic;

  /// No description provided for @albergueReviewRequestTopicDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to review albergues you\'ve stayed at'**
  String get albergueReviewRequestTopicDescription;

  /// Subtitle shown on an inbox notification asking the user to review an albergue
  ///
  /// In en, this message translates to:
  /// **'Awaiting your review'**
  String get awaitingYourReview;

  /// No description provided for @announcementsTopic.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTopic;

  /// No description provided for @announcementsTopicDescription.
  ///
  /// In en, this message translates to:
  /// **'Trail updates, route changes, and community news'**
  String get announcementsTopicDescription;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  ///
  ///
  /// In en, this message translates to:
  /// **'The Ninja App does not believe you are on {routeName}'**
  String appNotBelieveYouAreOnRoute(Object routeName);

  /// No description provided for @appRestrictionNote.
  ///
  /// In en, this message translates to:
  /// **'Can only be scanned/imported within\nCamino Ninja app'**
  String get appRestrictionNote;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @april11ToOct16.
  ///
  /// In en, this message translates to:
  /// **'April 11 to October 16'**
  String get april11ToOct16;

  /// No description provided for @april15ToNov15.
  ///
  /// In en, this message translates to:
  /// **'April 15 to November 15'**
  String get april15ToNov15;

  /// No description provided for @april15ToNovember30.
  ///
  /// In en, this message translates to:
  /// **'April 15 to November 30'**
  String get april15ToNovember30;

  /// No description provided for @april15ToOct31_620.
  ///
  /// In en, this message translates to:
  /// **'April 15 to October 31'**
  String get april15ToOct31_620;

  /// No description provided for @april15ToOctober15.
  ///
  /// In en, this message translates to:
  /// **'April 15 to October 15'**
  String get april15ToOctober15;

  /// No description provided for @april15ToSept30.
  ///
  /// In en, this message translates to:
  /// **'April 15 to September 30'**
  String get april15ToSept30;

  /// No description provided for @april1ToDec10.
  ///
  /// In en, this message translates to:
  /// **'April 1 to December 10'**
  String get april1ToDec10;

  /// No description provided for @april1ToDec19.
  ///
  /// In en, this message translates to:
  /// **'April 1 to December 19'**
  String get april1ToDec19;

  /// No description provided for @april1ToDecember31.
  ///
  /// In en, this message translates to:
  /// **'April 1 to December 31'**
  String get april1ToDecember31;

  /// No description provided for @april1ToNov12.
  ///
  /// In en, this message translates to:
  /// **'April 1 to November 12'**
  String get april1ToNov12;

  /// No description provided for @april1ToNov15_541.
  ///
  /// In en, this message translates to:
  /// **'April 1 to November 15'**
  String get april1ToNov15_541;

  /// No description provided for @april1ToNov1_581.
  ///
  /// In en, this message translates to:
  /// **'April 1 to November 1'**
  String get april1ToNov1_581;

  /// No description provided for @april1ToNov3.
  ///
  /// In en, this message translates to:
  /// **'April 1 to November 3'**
  String get april1ToNov3;

  /// No description provided for @april1ToNovember30.
  ///
  /// In en, this message translates to:
  /// **'April 1 to November 30'**
  String get april1ToNovember30;

  /// No description provided for @april1ToOct16_565.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 16'**
  String get april1ToOct16_565;

  /// No description provided for @april1ToOct30.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 30'**
  String get april1ToOct30;

  /// No description provided for @april1ToOct30_556.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 30'**
  String get april1ToOct30_556;

  /// No description provided for @april1ToOctober15.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 15'**
  String get april1ToOctober15;

  /// No description provided for @april1ToOctober31.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31'**
  String get april1ToOctober31;

  /// No description provided for @april1ToOctober31MonToFri.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31, from Monday to Friday'**
  String get april1ToOctober31MonToFri;

  /// No description provided for @april1ToOctober31RestConfirm.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31 (rest of the year consult)'**
  String get april1ToOctober31RestConfirm;

  /// No description provided for @april1ToOctober31RestGroupsReservation.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31 (rest of year only reservations by groups)'**
  String get april1ToOctober31RestGroupsReservation;

  /// No description provided for @april1ToOctober31RestGroupsReservation_187.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31 (rest of year only groups by reservation)'**
  String get april1ToOctober31RestGroupsReservation_187;

  /// No description provided for @april1ToOctober31RestGroupsReserve_215.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31 (rest of year groups can reserve)'**
  String get april1ToOctober31RestGroupsReserve_215;

  /// No description provided for @april1ToOctober31RestReservation.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31, rest of the year by reservation'**
  String get april1ToOctober31RestReservation;

  /// No description provided for @april1ToOctober31RestReservation_226.
  ///
  /// In en, this message translates to:
  /// **'April 1 to October 31, rest of year only with reservation'**
  String get april1ToOctober31RestReservation_226;

  /// No description provided for @april1ToSeptember30_214.
  ///
  /// In en, this message translates to:
  /// **'April 1 to September 30'**
  String get april1ToSeptember30_214;

  /// No description provided for @april7ToOct15.
  ///
  /// In en, this message translates to:
  /// **'April 7 to October 15'**
  String get april7ToOct15;

  /// No description provided for @april9ToOctober15.
  ///
  /// In en, this message translates to:
  /// **'April 9 to October 15'**
  String get april9ToOctober15;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'1 bed'**
  String get bed;

  /// No description provided for @bedSharedRoom.
  ///
  /// In en, this message translates to:
  /// **'Bed in shared room'**
  String get bedSharedRoom;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'{numberBunkbeds} beds'**
  String beds(Object numberBunkbeds);

  /// No description provided for @bedsDormitories.
  ///
  /// In en, this message translates to:
  /// **'{numberBunkbeds} beds in {numberDormitories} dormitories'**
  String bedsDormitories(Object numberBunkbeds, Object numberDormitories);

  /// No description provided for @bedsDormitory.
  ///
  /// In en, this message translates to:
  /// **'{numberBunkbeds} beds in 1 dormitory'**
  String bedsDormitory(Object numberBunkbeds);

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @breakfastIncluded.
  ///
  /// In en, this message translates to:
  /// **'Breakfast is included'**
  String get breakfastIncluded;

  ///
  ///
  /// In en, this message translates to:
  /// **'A screenshot was captured when you shook your device. You’ll see it in the next step.'**
  String get bugReportContent;

  ///
  ///
  /// In en, this message translates to:
  /// **'You can add more screenshots and details to help us improve Camino Ninja.'**
  String get bugReportDescription;

  /// No description provided for @bugReportDescriptionNew.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened and attach a screenshot. This helps our team find a solution faster.'**
  String get bugReportDescriptionNew;

  ///
  ///
  /// In en, this message translates to:
  /// **'Please try submitting your bug report again.'**
  String get bugReportFailureDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Thanks for helping us make Camino Ninja better!'**
  String get bugReportSuccessDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Bug reported successfully'**
  String get bugReportSuccessTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'We’ve captured the screen where the issue occurred'**
  String get bugReportTitle;

  /// No description provided for @bunkBed.
  ///
  /// In en, this message translates to:
  /// **'Bunk Bed'**
  String get bunkBed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-In'**
  String get checkIn;

  /// No description provided for @checkInTouristOffice.
  ///
  /// In en, this message translates to:
  /// **'Check-In is at the tourist office'**
  String get checkInTouristOffice;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @choseThisCity.
  ///
  /// In en, this message translates to:
  /// **'chose this city'**
  String get choseThisCity;

  /// No description provided for @citiesAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Cities with accommodation'**
  String get citiesAccommodation;

  /// No description provided for @cityPastDestination.
  ///
  /// In en, this message translates to:
  /// **'This city is past your destination. Continue and pick a new destination?'**
  String get cityPastDestination;

  ///
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  ///
  ///
  /// In en, this message translates to:
  /// **'Click here to turn it on'**
  String get clickHereToTurnItOn;

  ///
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @closedFebMarchSomeDec.
  ///
  /// In en, this message translates to:
  /// **'Closed February, March and some days of December'**
  String get closedFebMarchSomeDec;

  /// No description provided for @closedTuesdays15DaysSeptember.
  ///
  /// In en, this message translates to:
  /// **'Closed on Tuesdays and 15 days in September'**
  String get closedTuesdays15DaysSeptember;

  /// No description provided for @closedWednesdays.
  ///
  /// In en, this message translates to:
  /// **'Closed on Wednesdays'**
  String get closedWednesdays;

  /// No description provided for @closed_536.
  ///
  /// In en, this message translates to:
  /// **'Closed 2021'**
  String get closed_536;

  /// No description provided for @clothesline.
  ///
  /// In en, this message translates to:
  /// **'Clothesline'**
  String get clothesline;

  /// No description provided for @communityDinner.
  ///
  /// In en, this message translates to:
  /// **'Community Dinner'**
  String get communityDinner;

  /// No description provided for @communityDinnerIncluded_445.
  ///
  /// In en, this message translates to:
  /// **'Community Dinner Included'**
  String get communityDinnerIncluded_445;

  /// No description provided for @communityLunch.
  ///
  /// In en, this message translates to:
  /// **'Community Lunch'**
  String get communityLunch;

  ///
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDeletePlannedRoute.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the Planned Route'**
  String get confirmDeletePlannedRoute;

  /// No description provided for @confirmDeleteStage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this stage?'**
  String get confirmDeleteStage;

  /// No description provided for @confirmSaveChange.
  ///
  /// In en, this message translates to:
  /// **'Looks like you’ve made a change. Do you want to save it?'**
  String get confirmSaveChange;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact {name}'**
  String contactPerson(Object name);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  ///
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @cookingPots.
  ///
  /// In en, this message translates to:
  /// **'Cooking Pots'**
  String get cookingPots;

  /// No description provided for @cooktops.
  ///
  /// In en, this message translates to:
  /// **'Cooktops'**
  String get cooktops;

  /// No description provided for @cottonSheetsPillowcases.
  ///
  /// In en, this message translates to:
  /// **'Cotton Sheets & Pillowcases'**
  String get cottonSheetsPillowcases;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get couldNotLoadNotifications;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createNewStage.
  ///
  /// In en, this message translates to:
  /// **'Create New Stage'**
  String get createNewStage;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @creatingStagesFor.
  ///
  /// In en, this message translates to:
  /// **'Creating stages for'**
  String get creatingStagesFor;

  /// No description provided for @cubeBeds.
  ///
  /// In en, this message translates to:
  /// **'Cube Beds'**
  String get cubeBeds;

  /// No description provided for @currentElev.
  ///
  /// In en, this message translates to:
  /// **'Current Elev.'**
  String get currentElev;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'You are currently using version'**
  String get currentVersion;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @dayBefore.
  ///
  /// In en, this message translates to:
  /// **'Only the day before'**
  String get dayBefore;

  /// No description provided for @dayGap.
  ///
  /// In en, this message translates to:
  /// **'day gap'**
  String get dayGap;

  /// Label for nights staying at a stop, singular/plural based on count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Night at stop} other{Nights at stop}}'**
  String nightsAtStop(int count);

  /// No description provided for @daysGap.
  ///
  /// In en, this message translates to:
  /// **'days gap'**
  String get daysGap;

  /// No description provided for @dec19ToJan3_505.
  ///
  /// In en, this message translates to:
  /// **'December 19 to January 3'**
  String get dec19ToJan3_505;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your Camino Ninja account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAction;

  /// No description provided for @deleteErasedNote.
  ///
  /// In en, this message translates to:
  /// **'Once confirmed, your account will be erased along with all of your'**
  String get deleteErasedNote;

  /// No description provided for @deleteExitGreeting.
  ///
  /// In en, this message translates to:
  /// **'Buen Camino on your next journey!'**
  String get deleteExitGreeting;

  /// No description provided for @deleteNoteBold.
  ///
  /// In en, this message translates to:
  /// **'permanent and immediate'**
  String get deleteNoteBold;

  /// No description provided for @deleteNoteEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get deleteNoteEnd;

  /// No description provided for @deleteNoteStart.
  ///
  /// In en, this message translates to:
  /// **'Please note that this action is '**
  String get deleteNoteStart;

  /// No description provided for @deleteSorryToGo.
  ///
  /// In en, this message translates to:
  /// **'We’re sorry to see you go.'**
  String get deleteSorryToGo;

  /// No description provided for @deleteThisPlan.
  ///
  /// In en, this message translates to:
  /// **'Delete this plan'**
  String get deleteThisPlan;

  /// No description provided for @deleteThisStage.
  ///
  /// In en, this message translates to:
  /// **'Delete this stage'**
  String get deleteThisStage;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @dependentMonth.
  ///
  /// In en, this message translates to:
  /// **'Dependent on the month'**
  String get dependentMonth;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @dinnerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Dinner Available'**
  String get dinnerAvailable;

  /// No description provided for @dinnerIncluded_444.
  ///
  /// In en, this message translates to:
  /// **'Dinner Included'**
  String get dinnerIncluded_444;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'dist.'**
  String get distance;

  /// No description provided for @distanceFromCity.
  ///
  /// In en, this message translates to:
  /// **'I am {distance} km from {cityName} in a direct line. The location closest to me on {routeName}.'**
  String distanceFromCity(Object cityName, Object distance, Object routeName);

  /// No description provided for @distanceFromRoute.
  ///
  /// In en, this message translates to:
  /// **'Distance from route (included)'**
  String get distanceFromRoute;

  /// No description provided for @distanceFromTheTrail.
  ///
  /// In en, this message translates to:
  /// **'Distance from the trail'**
  String get distanceFromTheTrail;

  /// No description provided for @distance_344.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance_344;

  ///
  ///
  /// In en, this message translates to:
  /// **'Don’t ask me again'**
  String get doNotAskMeAgain;

  ///
  ///
  /// In en, this message translates to:
  /// **'Don’t show this again'**
  String get doNotShowThisAgain;

  /// No description provided for @donativoBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Donativo Breakfast'**
  String get donativoBreakfast;

  /// No description provided for @dontAskAgainAndDisable.
  ///
  /// In en, this message translates to:
  /// **'Don‘t ask me again and disable this shake-to-report feature for me'**
  String get dontAskAgainAndDisable;

  /// No description provided for @doorsClose.
  ///
  /// In en, this message translates to:
  /// **'Doors Closes'**
  String get doorsClose;

  /// No description provided for @doubleRoom.
  ///
  /// In en, this message translates to:
  /// **'Double Room'**
  String get doubleRoom;

  /// No description provided for @dutchOwnersDinner.
  ///
  /// In en, this message translates to:
  /// **'Dutch owners. Expect a good hearty dinner.'**
  String get dutchOwnersDinner;

  /// No description provided for @easterAndMay1ToOctober15.
  ///
  /// In en, this message translates to:
  /// **'Easter and from May 1 to October 15'**
  String get easterAndMay1ToOctober15;

  /// No description provided for @easterAndMay1ToOctober_224.
  ///
  /// In en, this message translates to:
  /// **'Easter and from May 1 to October 31'**
  String get easterAndMay1ToOctober_224;

  /// No description provided for @easterToDec11_604.
  ///
  /// In en, this message translates to:
  /// **'Easter to December 11'**
  String get easterToDec11_604;

  /// No description provided for @easterToNov30RestGroups20.
  ///
  /// In en, this message translates to:
  /// **'Easter to November 30 (rest of year only for groups of 20 or more with reservation)'**
  String get easterToNov30RestGroups20;

  /// No description provided for @easterToNov30RestReservation.
  ///
  /// In en, this message translates to:
  /// **'Easter to November 30 (rest of the year by reservation)'**
  String get easterToNov30RestReservation;

  /// No description provided for @easterToNovember15_128.
  ///
  /// In en, this message translates to:
  /// **'Easter to November 15'**
  String get easterToNovember15_128;

  /// No description provided for @easterToNovember30.
  ///
  /// In en, this message translates to:
  /// **'Easter to November 30'**
  String get easterToNovember30;

  /// No description provided for @easterToOct12.
  ///
  /// In en, this message translates to:
  /// **'Easter to October 12'**
  String get easterToOct12;

  /// No description provided for @easterToOctober15.
  ///
  /// In en, this message translates to:
  /// **'Easter to October 15'**
  String get easterToOctober15;

  /// No description provided for @easterToOctober31.
  ///
  /// In en, this message translates to:
  /// **'Easter to October 31'**
  String get easterToOctober31;

  /// No description provided for @easterToOctober31Groups.
  ///
  /// In en, this message translates to:
  /// **'Easter to October 31 (Rest of the year only open for large groups with reservation)'**
  String get easterToOctober31Groups;

  /// No description provided for @easterToOctober_114.
  ///
  /// In en, this message translates to:
  /// **'Easter to October 15'**
  String get easterToOctober_114;

  /// No description provided for @easterToSeptember30.
  ///
  /// In en, this message translates to:
  /// **'Easter to September 30'**
  String get easterToSeptember30;

  /// No description provided for @eightBedsDonation.
  ///
  /// In en, this message translates to:
  /// **'There\'s only 8 beds for donation and they are given as people arrive. No reservation. It is only for the pilgrims walking the true way.'**
  String get eightBedsDonation;

  /// No description provided for @elevation.
  ///
  /// In en, this message translates to:
  /// **'elev.'**
  String get elevation;

  ///
  ///
  /// In en, this message translates to:
  /// **'elev. gain/loss'**
  String get elevationGainLossRouteScreen;

  /// No description provided for @elevation_342.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get elevation_342;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  ///
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalidInlineError;

  /// No description provided for @enableLocationAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Enable location accuracy'**
  String get enableLocationAccuracy;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @endFebToEndDec.
  ///
  /// In en, this message translates to:
  /// **'End of February to end of December'**
  String get endFebToEndDec;

  /// No description provided for @endOfStage.
  ///
  /// In en, this message translates to:
  /// **'End of stage'**
  String get endOfStage;

  /// No description provided for @enterSomething.
  ///
  /// In en, this message translates to:
  /// **'Enter something'**
  String get enterSomething;

  ///
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Could not load announcements'**
  String get errorLoadingAnnouncements;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export Error'**
  String get exportError;

  /// No description provided for @facility_airport.
  ///
  /// In en, this message translates to:
  /// **'Airport'**
  String get facility_airport;

  /// No description provided for @facility_atm.
  ///
  /// In en, this message translates to:
  /// **'ATM'**
  String get facility_atm;

  /// No description provided for @facility_bus_station.
  ///
  /// In en, this message translates to:
  /// **'Bus Station'**
  String get facility_bus_station;

  /// No description provided for @facility_cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get facility_cafe;

  /// No description provided for @facility_clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get facility_clinic;

  /// No description provided for @facility_fountain.
  ///
  /// In en, this message translates to:
  /// **'Fountain'**
  String get facility_fountain;

  /// No description provided for @facility_hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get facility_hotel;

  /// No description provided for @facility_pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get facility_pharmacy;

  /// No description provided for @facility_post_office.
  ///
  /// In en, this message translates to:
  /// **'Post Office'**
  String get facility_post_office;

  /// No description provided for @facility_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get facility_restaurant;

  /// No description provided for @facility_shopping_stores.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get facility_shopping_stores;

  /// No description provided for @facility_tobacco_shop.
  ///
  /// In en, this message translates to:
  /// **'Tobacconist'**
  String get facility_tobacco_shop;

  /// No description provided for @facility_train_station.
  ///
  /// In en, this message translates to:
  /// **'Train Station'**
  String get facility_train_station;

  /// No description provided for @feb10ToDec15.
  ///
  /// In en, this message translates to:
  /// **'February 10 to December 15'**
  String get feb10ToDec15;

  /// No description provided for @feb12ToDec12.
  ///
  /// In en, this message translates to:
  /// **'February 12 to December 12'**
  String get feb12ToDec12;

  /// No description provided for @feb15ToDec12_658.
  ///
  /// In en, this message translates to:
  /// **'February 15 to December 12'**
  String get feb15ToDec12_658;

  /// No description provided for @feb15ToDec31_458.
  ///
  /// In en, this message translates to:
  /// **'February 15 to December 31'**
  String get feb15ToDec31_458;

  /// No description provided for @feb15ToNov30_521.
  ///
  /// In en, this message translates to:
  /// **'February 15 to November 30'**
  String get feb15ToNov30_521;

  /// No description provided for @feb15ToOct31.
  ///
  /// In en, this message translates to:
  /// **'February 15 to October 31'**
  String get feb15ToOct31;

  /// No description provided for @feb16ToNov30RestGroups4To10.
  ///
  /// In en, this message translates to:
  /// **'February 16 to November 30 (rest of year groups of 4 to 10 can reserve)'**
  String get feb16ToNov30RestGroups4To10;

  /// No description provided for @feb16ToOct31.
  ///
  /// In en, this message translates to:
  /// **'February 16 to October 31'**
  String get feb16ToOct31;

  /// No description provided for @feb16ToOct31_600.
  ///
  /// In en, this message translates to:
  /// **'February 16 to October 31'**
  String get feb16ToOct31_600;

  /// No description provided for @feb1ToDec11_623.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 11'**
  String get feb1ToDec11_623;

  /// No description provided for @feb1ToDec12.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 12'**
  String get feb1ToDec12;

  /// No description provided for @feb1ToDec14_615.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 14'**
  String get feb1ToDec14_615;

  /// No description provided for @feb1ToDec19ClosedSunFebNovToDec.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 19 (closed on Sundays in February and November 1 to December 19)'**
  String get feb1ToDec19ClosedSunFebNovToDec;

  /// No description provided for @feb1ToDec19_618.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 19'**
  String get feb1ToDec19_618;

  /// No description provided for @feb1ToDec19_624.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 19'**
  String get feb1ToDec19_624;

  /// No description provided for @feb1ToDec23WeekendsFeb.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 23 (only open in weekends in February)'**
  String get feb1ToDec23WeekendsFeb;

  /// No description provided for @feb1ToDec31_657.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 31'**
  String get feb1ToDec31_657;

  /// No description provided for @feb1ToDec7.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 7'**
  String get feb1ToDec7;

  /// No description provided for @feb1ToDec9_694.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 9'**
  String get feb1ToDec9_694;

  /// No description provided for @feb1ToNov11.
  ///
  /// In en, this message translates to:
  /// **'February 1 to November 11'**
  String get feb1ToNov11;

  /// No description provided for @feb1ToNov14.
  ///
  /// In en, this message translates to:
  /// **'February 1 to November 14'**
  String get feb1ToNov14;

  /// No description provided for @feb1ToOct31_457.
  ///
  /// In en, this message translates to:
  /// **'February 1 to October 31'**
  String get feb1ToOct31_457;

  /// No description provided for @feb1ToSept30.
  ///
  /// In en, this message translates to:
  /// **'February 1 to September 30'**
  String get feb1ToSept30;

  /// No description provided for @feb22ToDec22.
  ///
  /// In en, this message translates to:
  /// **'Februar 22 to December 22'**
  String get feb22ToDec22;

  /// No description provided for @feb26ToDec11.
  ///
  /// In en, this message translates to:
  /// **'February 26 to December 11'**
  String get feb26ToDec11;

  /// No description provided for @feb26ToOct31.
  ///
  /// In en, this message translates to:
  /// **'February 26 to October 31'**
  String get feb26ToOct31;

  /// No description provided for @feb27ToDec9.
  ///
  /// In en, this message translates to:
  /// **'February 27 to December 9'**
  String get feb27ToDec9;

  /// No description provided for @feb7ToNov30.
  ///
  /// In en, this message translates to:
  /// **'February 7 to November 30'**
  String get feb7ToNov30;

  /// No description provided for @feb8ToDec19.
  ///
  /// In en, this message translates to:
  /// **'February 8 to December 19'**
  String get feb8ToDec19;

  /// No description provided for @february15ToDecember15.
  ///
  /// In en, this message translates to:
  /// **'February 15 to December 15'**
  String get february15ToDecember15;

  /// No description provided for @february1ToDecember15.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 15'**
  String get february1ToDecember15;

  /// No description provided for @february1ToDecember21.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 21'**
  String get february1ToDecember21;

  /// No description provided for @february1ToDecember31.
  ///
  /// In en, this message translates to:
  /// **'February 1 to December 31'**
  String get february1ToDecember31;

  /// No description provided for @february1ToNovember30_141.
  ///
  /// In en, this message translates to:
  /// **'February 1 to November 30'**
  String get february1ToNovember30_141;

  /// No description provided for @february1ToNovember30_171.
  ///
  /// In en, this message translates to:
  /// **'February 1 to November 30'**
  String get february1ToNovember30_171;

  /// No description provided for @february1ToNovember5.
  ///
  /// In en, this message translates to:
  /// **'February 1 to November 5'**
  String get february1ToNovember5;

  /// No description provided for @february28ToOctober31.
  ///
  /// In en, this message translates to:
  /// **'February 28 to October 31'**
  String get february28ToOctober31;

  ///
  ///
  /// In en, this message translates to:
  /// **'Let us know if you spot anything off or missing.'**
  String get feedbackAlbergueBottomSheetDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'How could we improve Camino Ninja?'**
  String get feedbackAlbergueBottomSheetTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Feedback is required'**
  String get feedbackIsRequired;

  ///
  ///
  /// In en, this message translates to:
  /// **'Feedback Submission Failed'**
  String get feedbackSubmissionFailed;

  ///
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your feedback. You\'ll be notified if it\'s approved and displayed here.'**
  String get feedbackSubmitSuccessMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Feedback Submitted'**
  String get feedbackSubmitted;

  ///
  ///
  /// In en, this message translates to:
  /// **'Fetching routes and markers'**
  String get fetchingRoutesAndMarkers;

  /// No description provided for @findTransportation.
  ///
  /// In en, this message translates to:
  /// **'Find transportation'**
  String get findTransportation;

  /// No description provided for @fiveEuroPerDog.
  ///
  /// In en, this message translates to:
  /// **'they charge 5 euros for each dog'**
  String get fiveEuroPerDog;

  /// No description provided for @freeStayWelcome.
  ///
  /// In en, this message translates to:
  /// **'People who cant pay are still welcome.'**
  String get freeStayWelcome;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @fromEaster.
  ///
  /// In en, this message translates to:
  /// **'From Easter'**
  String get fromEaster;

  /// No description provided for @fromMarch15.
  ///
  /// In en, this message translates to:
  /// **'From March 15'**
  String get fromMarch15;

  /// No description provided for @fromMarch1_238.
  ///
  /// In en, this message translates to:
  /// **'From March 1'**
  String get fromMarch1_238;

  /// No description provided for @fullLaundryService.
  ///
  /// In en, this message translates to:
  /// **'Full Laundry Service'**
  String get fullLaundryService;

  ///
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Give a rating for this accommodation'**
  String get giveARatingForThisAccommodation;

  /// No description provided for @goToHereToday.
  ///
  /// In en, this message translates to:
  /// **'I\'ll go here today'**
  String get goToHereToday;

  /// No description provided for @handWashingSink.
  ///
  /// In en, this message translates to:
  /// **'Hand Washing Sink'**
  String get handWashingSink;

  /// No description provided for @headOfCaminoNinja.
  ///
  /// In en, this message translates to:
  /// **'Head of Camino Ninja'**
  String get headOfCaminoNinja;

  /// No description provided for @headOfData.
  ///
  /// In en, this message translates to:
  /// **'Head of Data'**
  String get headOfData;

  ///
  ///
  /// In en, this message translates to:
  /// **'Help us improve Camino Ninja'**
  String get helpUsImproveCaminoNinja;

  /// No description provided for @here.
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get here;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @hostel4Km.
  ///
  /// In en, this message translates to:
  /// **'The hostel is 4 km from the route'**
  String get hostel4Km;

  /// No description provided for @howWasYourStay.
  ///
  /// In en, this message translates to:
  /// **'How was your stay?'**
  String get howWasYourStay;

  ///
  ///
  /// In en, this message translates to:
  /// **'I’ll go here'**
  String get iWillGoHere;

  /// No description provided for @iWillGoThere.
  ///
  /// In en, this message translates to:
  /// **'I\'ll go there'**
  String get iWillGoThere;

  /// No description provided for @iWillStartHere.
  ///
  /// In en, this message translates to:
  /// **'I\'ll start here'**
  String get iWillStartHere;

  /// No description provided for @iWillStayHere.
  ///
  /// In en, this message translates to:
  /// **'I\'ll stay here'**
  String get iWillStayHere;

  /// No description provided for @iWillStayHereOptional.
  ///
  /// In en, this message translates to:
  /// **'I\'ll stay here (optional)'**
  String get iWillStayHereOptional;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import Success'**
  String get importSuccess;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// No description provided for @importingPlans.
  ///
  /// In en, this message translates to:
  /// **'Importing plans'**
  String get importingPlans;

  ///
  ///
  /// In en, this message translates to:
  /// **'We are looking forward to reading your love letter! Please write it as a review in the {storeName}.'**
  String inAppReviewContentV1(Object storeName);

  ///
  ///
  /// In en, this message translates to:
  /// **'If so, please write it as a review in the {storeName}.'**
  String inAppReviewContentV2(Object storeName);

  ///
  ///
  /// In en, this message translates to:
  /// **'If so, please write it as a review in the {storeName}.'**
  String inAppReviewContentV3(Object storeName);

  ///
  ///
  /// In en, this message translates to:
  /// **'We are looking forward to reading your love letter! Please write it as a review in the {storeName}.'**
  String inAppReviewContentV4(Object storeName);

  ///
  ///
  /// In en, this message translates to:
  /// **'Do you also love Camino Ninja?'**
  String get inAppReviewDescriptionV1;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are we also your favorite app?'**
  String get inAppReviewDescriptionV2;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are we also a wonderful app?'**
  String get inAppReviewDescriptionV3;

  ///
  ///
  /// In en, this message translates to:
  /// **'Do you also love Camino Ninja?'**
  String get inAppReviewDescriptionV4;

  ///
  ///
  /// In en, this message translates to:
  /// **'We love you!'**
  String get inAppReviewTitleV1;

  ///
  ///
  /// In en, this message translates to:
  /// **'You are our favorite user!'**
  String get inAppReviewTitleV2;

  ///
  ///
  /// In en, this message translates to:
  /// **'You are a wonderful pilgrim!'**
  String get inAppReviewTitleV3;

  ///
  ///
  /// In en, this message translates to:
  /// **'Camino Ninja loves you!'**
  String get inAppReviewTitleV4;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @individualPowerPlugs.
  ///
  /// In en, this message translates to:
  /// **'Individual Power Plugs'**
  String get individualPowerPlugs;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @jan10ToDec23.
  ///
  /// In en, this message translates to:
  /// **'January 10 to December 23'**
  String get jan10ToDec23;

  /// No description provided for @jan10ToDec23ExceptDec3To9.
  ///
  /// In en, this message translates to:
  /// **'January 10 to December 23, except December 3 to 9'**
  String get jan10ToDec23ExceptDec3To9;

  /// No description provided for @jan10ToDec23ManyExceptions.
  ///
  /// In en, this message translates to:
  /// **'January 10 to December 23, except February 26 to March 2, November 20 and 27 to 28, December 3 to 12'**
  String get jan10ToDec23ManyExceptions;

  /// No description provided for @jan10ToDec9.
  ///
  /// In en, this message translates to:
  /// **'January 10 to December 9'**
  String get jan10ToDec9;

  /// No description provided for @jan11ToDec19_499.
  ///
  /// In en, this message translates to:
  /// **'January 11 to December 19'**
  String get jan11ToDec19_499;

  /// No description provided for @jan11ToDec19_572.
  ///
  /// In en, this message translates to:
  /// **'January 11 to December 19'**
  String get jan11ToDec19_572;

  /// No description provided for @jan15ToDec31ExceptOct.
  ///
  /// In en, this message translates to:
  /// **'January 15 to December 31, except last week in October'**
  String get jan15ToDec31ExceptOct;

  /// No description provided for @jan17ToDec12.
  ///
  /// In en, this message translates to:
  /// **'January 17 to December 12'**
  String get jan17ToDec12;

  /// No description provided for @jan17ToDec19.
  ///
  /// In en, this message translates to:
  /// **'January 17 to December 19'**
  String get jan17ToDec19;

  /// No description provided for @jan1ToDec21_622.
  ///
  /// In en, this message translates to:
  /// **'January 1 to December 21'**
  String get jan1ToDec21_622;

  /// No description provided for @jan1ToDec22_630.
  ///
  /// In en, this message translates to:
  /// **'January 1 to December 22'**
  String get jan1ToDec22_630;

  /// No description provided for @jan1ToNov30.
  ///
  /// In en, this message translates to:
  /// **'January 1 to November 30'**
  String get jan1ToNov30;

  /// No description provided for @jan1ToOct31.
  ///
  /// In en, this message translates to:
  /// **'January 1 to October 31'**
  String get jan1ToOct31;

  /// No description provided for @jan21ToDec14_640.
  ///
  /// In en, this message translates to:
  /// **'January 21 to December 14'**
  String get jan21ToDec14_640;

  /// No description provided for @jan21ToDec15FriToSun.
  ///
  /// In en, this message translates to:
  /// **'January 21 to December 15 (only open Fridays to Sundays from January 21 to March 31 and November 1 to December 15)'**
  String get jan21ToDec15FriToSun;

  /// No description provided for @jan21ToDec19_636.
  ///
  /// In en, this message translates to:
  /// **'January 21 to December 19'**
  String get jan21ToDec19_636;

  /// No description provided for @jan21ToDec19_671.
  ///
  /// In en, this message translates to:
  /// **'January 21 to December 19'**
  String get jan21ToDec19_671;

  /// No description provided for @jan22ToDec18.
  ///
  /// In en, this message translates to:
  /// **'January 22 to December 18'**
  String get jan22ToDec18;

  /// No description provided for @jan25ToDec20.
  ///
  /// In en, this message translates to:
  /// **'January 25 to December 20'**
  String get jan25ToDec20;

  /// No description provided for @jan26ToDec24ClosedMondays.
  ///
  /// In en, this message translates to:
  /// **'January 26 to December 24 (closed on Mondays in November, December, January and February)'**
  String get jan26ToDec24ClosedMondays;

  /// No description provided for @jan2ToDec19.
  ///
  /// In en, this message translates to:
  /// **'January 2 to December 19'**
  String get jan2ToDec19;

  /// No description provided for @jan2ToDec22.
  ///
  /// In en, this message translates to:
  /// **'January 2 to December 22'**
  String get jan2ToDec22;

  /// No description provided for @jan2ToDec24.
  ///
  /// In en, this message translates to:
  /// **'January 2 to December 24'**
  String get jan2ToDec24;

  /// No description provided for @jan2ToDec24ExceptNov15To30.
  ///
  /// In en, this message translates to:
  /// **'January 2 to December 24, except November 15 to 30'**
  String get jan2ToDec24ExceptNov15To30;

  /// No description provided for @jan3ToDec22_617.
  ///
  /// In en, this message translates to:
  /// **'January 3 to December 22'**
  String get jan3ToDec22_617;

  /// No description provided for @jan3ToDec23.
  ///
  /// In en, this message translates to:
  /// **'January 3 to December 23'**
  String get jan3ToDec23;

  /// No description provided for @jan4ToDec21.
  ///
  /// In en, this message translates to:
  /// **'January 4 to December 21'**
  String get jan4ToDec21;

  /// No description provided for @jan6ToDec19.
  ///
  /// In en, this message translates to:
  /// **'January 6 to December 19'**
  String get jan6ToDec19;

  /// No description provided for @jan6ToDec22_597.
  ///
  /// In en, this message translates to:
  /// **'January 6 to December 22'**
  String get jan6ToDec22_597;

  /// No description provided for @jan6ToDec23.
  ///
  /// In en, this message translates to:
  /// **'January 6 to December 23'**
  String get jan6ToDec23;

  /// No description provided for @jan6ToOct31.
  ///
  /// In en, this message translates to:
  /// **'January 6 to October 31'**
  String get jan6ToOct31;

  /// No description provided for @jan7ToDec23.
  ///
  /// In en, this message translates to:
  /// **'January 7 to December 23'**
  String get jan7ToDec23;

  /// No description provided for @jan8ToDec11.
  ///
  /// In en, this message translates to:
  /// **'January 8 to December 11'**
  String get jan8ToDec11;

  /// No description provided for @jan8ToDec21_601.
  ///
  /// In en, this message translates to:
  /// **'January 8 to December 21'**
  String get jan8ToDec21_601;

  /// No description provided for @jan8ToDec21_669.
  ///
  /// In en, this message translates to:
  /// **'January 8 to December 21'**
  String get jan8ToDec21_669;

  /// No description provided for @jan8ToDec23_626.
  ///
  /// In en, this message translates to:
  /// **'January 8 to December 23'**
  String get jan8ToDec23_626;

  /// No description provided for @january15ToNovember30.
  ///
  /// In en, this message translates to:
  /// **'January 15 to November 30'**
  String get january15ToNovember30;

  /// No description provided for @january16ToDecember14.
  ///
  /// In en, this message translates to:
  /// **'January 16 to December 14'**
  String get january16ToDecember14;

  /// No description provided for @januaryToDecember.
  ///
  /// In en, this message translates to:
  /// **'January 1 to December 31'**
  String get januaryToDecember;

  /// No description provided for @july1ToAug30.
  ///
  /// In en, this message translates to:
  /// **'July 1 to August 30'**
  String get july1ToAug30;

  /// No description provided for @july1ToSept24_722.
  ///
  /// In en, this message translates to:
  /// **'July 1 to September 24'**
  String get july1ToSept24_722;

  /// No description provided for @july1ToSeptember15.
  ///
  /// In en, this message translates to:
  /// **'July 1 to September 15'**
  String get july1ToSeptember15;

  /// No description provided for @july20ToSept30.
  ///
  /// In en, this message translates to:
  /// **'July 20 to September 30'**
  String get july20ToSept30;

  /// No description provided for @june15ToOct31.
  ///
  /// In en, this message translates to:
  /// **'June 15 to October 31'**
  String get june15ToOct31;

  /// No description provided for @june16ToOct15.
  ///
  /// In en, this message translates to:
  /// **'June 16 to October 15'**
  String get june16ToOct15;

  /// No description provided for @june1ToOct30.
  ///
  /// In en, this message translates to:
  /// **'June 1 to October 30'**
  String get june1ToOct30;

  /// No description provided for @june1ToSeptember30.
  ///
  /// In en, this message translates to:
  /// **'June 1 to September 30'**
  String get june1ToSeptember30;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @kmMiles.
  ///
  /// In en, this message translates to:
  /// **'Km/Miles'**
  String get kmMiles;

  /// Word for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  ///
  ///
  /// In en, this message translates to:
  /// **'Languages Available'**
  String get languageAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  ///
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  ///
  ///
  /// In en, this message translates to:
  /// **'Latest price on'**
  String get latestPriceOn;

  /// No description provided for @laundryFree.
  ///
  /// In en, this message translates to:
  /// **'Laundry is free'**
  String get laundryFree;

  ///
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalAndPrivacy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Let us know if any information is incorrect'**
  String get letUsKnowIfAnyInformationIsIncorrect;

  /// No description provided for @letUsKnowStay.
  ///
  /// In en, this message translates to:
  /// **'Let us know how you’d like to stay in this city!'**
  String get letUsKnowStay;

  /// No description provided for @lightDark.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark'**
  String get lightDark;

  ///
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// Message shown during initial data loading
  ///
  /// In en, this message translates to:
  /// **'Loading route data...\n\nPlease wait a moment while we load the necessary data.\nThis will only happen once.\nYou can use the app offline after the initial loading is done.'**
  String get loadingMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Locate on other maps'**
  String get locateOnOtherMaps;

  /// No description provided for @locationAccuracyDetail.
  ///
  /// In en, this message translates to:
  /// **'your current position more accurately.'**
  String get locationAccuracyDetail;

  /// No description provided for @locationAccuracyIntro.
  ///
  /// In en, this message translates to:
  /// **'Turning on location accuracy helps us display '**
  String get locationAccuracyIntro;

  /// No description provided for @locationPermissionGuideAndroidStep1Part1.
  ///
  /// In en, this message translates to:
  /// **'\nGo to '**
  String get locationPermissionGuideAndroidStep1Part1;

  /// No description provided for @locationPermissionGuideAndroidStep1Part2BoldPath.
  ///
  /// In en, this message translates to:
  /// **'Settings > Location'**
  String get locationPermissionGuideAndroidStep1Part2BoldPath;

  /// No description provided for @locationPermissionGuideAndroidStep1Part3.
  ///
  /// In en, this message translates to:
  /// **' and turn on '**
  String get locationPermissionGuideAndroidStep1Part3;

  /// No description provided for @locationPermissionGuideAndroidStep1Part4BoldAction.
  ///
  /// In en, this message translates to:
  /// **'Location access.'**
  String get locationPermissionGuideAndroidStep1Part4BoldAction;

  /// No description provided for @locationPermissionGuideAndroidStep2Part1.
  ///
  /// In en, this message translates to:
  /// **'\nIn your app settings, also ensure '**
  String get locationPermissionGuideAndroidStep2Part1;

  /// No description provided for @locationPermissionGuideAndroidStep2Part2BoldAppName.
  ///
  /// In en, this message translates to:
  /// **'Camino Ninja'**
  String get locationPermissionGuideAndroidStep2Part2BoldAppName;

  /// No description provided for @locationPermissionGuideAndroidStep2Part3.
  ///
  /// In en, this message translates to:
  /// **' has permission to access your location.'**
  String get locationPermissionGuideAndroidStep2Part3;

  /// No description provided for @locationPermissionGuideHeaderPart1.
  ///
  /// In en, this message translates to:
  /// **'To explore the map, you’ll need to turn on '**
  String get locationPermissionGuideHeaderPart1;

  /// No description provided for @locationPermissionGuideHeaderPart2Bold.
  ///
  /// In en, this message translates to:
  /// **'Location Services.'**
  String get locationPermissionGuideHeaderPart2Bold;

  /// No description provided for @locationPermissionGuideHeaderPart3.
  ///
  /// In en, this message translates to:
  /// **'\nJust follow the steps for your device:'**
  String get locationPermissionGuideHeaderPart3;

  /// No description provided for @locationPermissionGuideIosStep1Part1.
  ///
  /// In en, this message translates to:
  /// **'\nGo to '**
  String get locationPermissionGuideIosStep1Part1;

  /// No description provided for @locationPermissionGuideIosStep1Part2BoldPath.
  ///
  /// In en, this message translates to:
  /// **'Settings > Privacy & Security > Location Services'**
  String get locationPermissionGuideIosStep1Part2BoldPath;

  /// No description provided for @locationPermissionGuideIosStep1Part3.
  ///
  /// In en, this message translates to:
  /// **' and turn on '**
  String get locationPermissionGuideIosStep1Part3;

  /// No description provided for @locationPermissionGuideIosStep1Part4BoldAction.
  ///
  /// In en, this message translates to:
  /// **'Location Services.'**
  String get locationPermissionGuideIosStep1Part4BoldAction;

  /// No description provided for @locationPermissionGuideIosStep2Part1.
  ///
  /// In en, this message translates to:
  /// **'\nIn the '**
  String get locationPermissionGuideIosStep2Part1;

  /// No description provided for @locationPermissionGuideIosStep2Part2BoldTerm.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get locationPermissionGuideIosStep2Part2BoldTerm;

  /// No description provided for @locationPermissionGuideIosStep2Part3.
  ///
  /// In en, this message translates to:
  /// **' settings, also ensure Camino Ninja has permission to access your location.'**
  String get locationPermissionGuideIosStep2Part3;

  /// No description provided for @locationPermissionGuideIosStep3Part1.
  ///
  /// In en, this message translates to:
  /// **'\nFor best accuracy, turn on '**
  String get locationPermissionGuideIosStep3Part1;

  /// No description provided for @locationPermissionGuideIosStep3Part2BoldAction.
  ///
  /// In en, this message translates to:
  /// **'Precise Location.'**
  String get locationPermissionGuideIosStep3Part2BoldAction;

  /// No description provided for @locationPermissionGuideIosStep3Part4.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get locationPermissionGuideIosStep3Part4;

  ///
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequired;

  /// No description provided for @locationRouteDestination.
  ///
  /// In en, this message translates to:
  /// **'Location, route & destination'**
  String get locationRouteDestination;

  /// No description provided for @loginRequiredUpload.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in, to upload'**
  String get loginRequiredUpload;

  /// No description provided for @loginToShare.
  ///
  /// In en, this message translates to:
  /// **'Log in to share or import plans.'**
  String get loginToShare;

  /// No description provided for @lunchAvailable.
  ///
  /// In en, this message translates to:
  /// **'Lunch Available'**
  String get lunchAvailable;

  /// No description provided for @manuallyAddStay.
  ///
  /// In en, this message translates to:
  /// **'Manually add my stay'**
  String get manuallyAddStay;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @march10ToDec23.
  ///
  /// In en, this message translates to:
  /// **'March 10 to December 23'**
  String get march10ToDec23;

  /// No description provided for @march12ToOct31.
  ///
  /// In en, this message translates to:
  /// **'March 12 to October 31'**
  String get march12ToOct31;

  /// No description provided for @march14ToDec11.
  ///
  /// In en, this message translates to:
  /// **'March 14 to December 11'**
  String get march14ToDec11;

  /// No description provided for @march15ToDec10_523.
  ///
  /// In en, this message translates to:
  /// **'March 15 to December 10'**
  String get march15ToDec10_523;

  /// No description provided for @march15ToDec11_715.
  ///
  /// In en, this message translates to:
  /// **'March 15 to December 11'**
  String get march15ToDec11_715;

  /// No description provided for @march15ToDec15ExceptNovGroups4.
  ///
  /// In en, this message translates to:
  /// **'March 15 to December 15, except November 15 to 30 (only for groups of 4 and more in December)'**
  String get march15ToDec15ExceptNovGroups4;

  /// No description provided for @march15ToDec15_554.
  ///
  /// In en, this message translates to:
  /// **'March 15 to December 15'**
  String get march15ToDec15_554;

  /// No description provided for @march15ToNov15ClosedMondays.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 15 (Closed on Mondays)'**
  String get march15ToNov15ClosedMondays;

  /// No description provided for @march15ToNov15ClosedMondays_668.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 15 (closed on Mondays)'**
  String get march15ToNov15ClosedMondays_668;

  /// No description provided for @march15ToNov15RestReservation.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 15, rest of year by reservation'**
  String get march15ToNov15RestReservation;

  /// No description provided for @march15ToNov28.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 28'**
  String get march15ToNov28;

  /// No description provided for @march15ToNov30_634.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 30'**
  String get march15ToNov30_634;

  /// No description provided for @march15ToNov5_700.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 5'**
  String get march15ToNov5_700;

  /// No description provided for @march15ToNovember15.
  ///
  /// In en, this message translates to:
  /// **'March 15 to November 15'**
  String get march15ToNovember15;

  /// No description provided for @march15ToOct15RestCall.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 15, rest of the year confirm'**
  String get march15ToOct15RestCall;

  /// No description provided for @march15ToOct23.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 23'**
  String get march15ToOct23;

  /// No description provided for @march15ToOct24ClosedMondays.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 24 (closed on mandays)'**
  String get march15ToOct24ClosedMondays;

  /// No description provided for @march15ToOctober15_130.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 15'**
  String get march15ToOctober15_130;

  /// No description provided for @march15ToOctober15_208.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 15'**
  String get march15ToOctober15_208;

  /// No description provided for @march15ToOctober15_227.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 15'**
  String get march15ToOctober15_227;

  /// No description provided for @march15ToOctober31_119.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 31'**
  String get march15ToOctober31_119;

  /// No description provided for @march15ToOctober31_180.
  ///
  /// In en, this message translates to:
  /// **'March 15 to October 31'**
  String get march15ToOctober31_180;

  /// No description provided for @march15ToSept30_558.
  ///
  /// In en, this message translates to:
  /// **'March 15 to September 30'**
  String get march15ToSept30_558;

  /// No description provided for @march15ToSept30_563.
  ///
  /// In en, this message translates to:
  /// **'March 15 to September 30'**
  String get march15ToSept30_563;

  /// No description provided for @march15ToSept30_686.
  ///
  /// In en, this message translates to:
  /// **'March 15 to September 30'**
  String get march15ToSept30_686;

  /// No description provided for @march15ToSeptember15.
  ///
  /// In en, this message translates to:
  /// **'March 15 to September 15'**
  String get march15ToSeptember15;

  /// No description provided for @march16ToDec14RestGroups.
  ///
  /// In en, this message translates to:
  /// **'March 16 to December 14 (rest of year only groups with reservations)'**
  String get march16ToDec14RestGroups;

  /// No description provided for @march18ToOctober19.
  ///
  /// In en, this message translates to:
  /// **'March 18 to October 19'**
  String get march18ToOctober19;

  /// No description provided for @march18ToOctober31.
  ///
  /// In en, this message translates to:
  /// **'March 18 to October 31'**
  String get march18ToOctober31;

  /// No description provided for @march19ToOct31_685.
  ///
  /// In en, this message translates to:
  /// **'March 19 to October 31'**
  String get march19ToOct31_685;

  /// No description provided for @march1ToDec10_528.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 10'**
  String get march1ToDec10_528;

  /// No description provided for @march1ToDec10_672.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 10'**
  String get march1ToDec10_672;

  /// No description provided for @march1ToDec10_695.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 10'**
  String get march1ToDec10_695;

  /// No description provided for @march1ToDec12_654.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 12'**
  String get march1ToDec12_654;

  /// No description provided for @march1ToDec14_606.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 14'**
  String get march1ToDec14_606;

  /// No description provided for @march1ToDec14_663.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 14'**
  String get march1ToDec14_663;

  /// No description provided for @march1ToDec15_649.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 15'**
  String get march1ToDec15_649;

  /// No description provided for @march1ToDec15_702.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 15'**
  String get march1ToDec15_702;

  /// No description provided for @march1ToDec18.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 18'**
  String get march1ToDec18;

  /// No description provided for @march1ToDec19RestGroups.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 19 (rest of the year only for groups with reservation)'**
  String get march1ToDec19RestGroups;

  /// No description provided for @march1ToDec20_550.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 20'**
  String get march1ToDec20_550;

  /// No description provided for @march1ToDec21_673.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 21'**
  String get march1ToDec21_673;

  /// No description provided for @march1ToDec22_707.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 22'**
  String get march1ToDec22_707;

  /// No description provided for @march1ToDec23_627.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 23'**
  String get march1ToDec23_627;

  /// No description provided for @march1ToDec31.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 31'**
  String get march1ToDec31;

  /// No description provided for @march1ToDec31_698.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 31'**
  String get march1ToDec31_698;

  /// No description provided for @march1ToDec8.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 8'**
  String get march1ToDec8;

  /// No description provided for @march1ToDecember8.
  ///
  /// In en, this message translates to:
  /// **'March 1 to December 8'**
  String get march1ToDecember8;

  /// No description provided for @march1ToNov10.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 10'**
  String get march1ToNov10;

  /// No description provided for @march1ToNov11.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 11'**
  String get march1ToNov11;

  /// No description provided for @march1ToNov15RestGroups4.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 15 (rest of year only open for groups of 4 people or more)'**
  String get march1ToNov15RestGroups4;

  /// No description provided for @march1ToNov19_610.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 19'**
  String get march1ToNov19_610;

  /// No description provided for @march1ToNov20.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 20'**
  String get march1ToNov20;

  /// No description provided for @march1ToNov26.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 26'**
  String get march1ToNov26;

  /// No description provided for @march1ToNov28_655.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 28'**
  String get march1ToNov28_655;

  /// No description provided for @march1ToNov30MayVary.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 30 (depending on the year, it may vary)'**
  String get march1ToNov30MayVary;

  /// No description provided for @march1ToNov30RestGroupsReservation.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 30 (rest of the year only for groups with reservation)'**
  String get march1ToNov30RestGroupsReservation;

  /// No description provided for @march1ToNov30RestGroupsReservation_203.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 30 (rest of the year by reservation by groups only)'**
  String get march1ToNov30RestGroupsReservation_203;

  /// No description provided for @march1ToNov30RestReservation_174.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 30 (rest of year by reservation)'**
  String get march1ToNov30RestReservation_174;

  /// No description provided for @march1ToNovember15.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 15'**
  String get march1ToNovember15;

  /// No description provided for @march1ToNovember30.
  ///
  /// In en, this message translates to:
  /// **'March 1 to November 30'**
  String get march1ToNovember30;

  /// No description provided for @march1ToOct24_570.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 24'**
  String get march1ToOct24_570;

  /// No description provided for @march1ToOct31ClosedSatSun.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31 (closed Saturdays and Sundays)'**
  String get march1ToOct31ClosedSatSun;

  /// No description provided for @march1ToOctober15.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 15'**
  String get march1ToOctober15;

  /// No description provided for @march1ToOctober31.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31'**
  String get march1ToOctober31;

  /// No description provided for @march1ToOctober31GroupsReserve.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31 (other months groups can reserve)'**
  String get march1ToOctober31GroupsReserve;

  /// No description provided for @march1ToOctober31Reservation.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31 (rest of the year according to reservations)'**
  String get march1ToOctober31Reservation;

  /// No description provided for @march1ToOctober31RestConfirm_123.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31, rest of year confirm'**
  String get march1ToOctober31RestConfirm_123;

  /// No description provided for @march1ToOctober31RestReservation_160.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31, rest of year make reservation'**
  String get march1ToOctober31RestReservation_160;

  /// No description provided for @march1ToOctober31RestThuSun.
  ///
  /// In en, this message translates to:
  /// **'March 1 to October 31, rest of year from Thursday to Sunday'**
  String get march1ToOctober31RestThuSun;

  /// No description provided for @march1ToSeptember30.
  ///
  /// In en, this message translates to:
  /// **'March 1 to September 30'**
  String get march1ToSeptember30;

  /// No description provided for @march20ToOct24.
  ///
  /// In en, this message translates to:
  /// **'March 20 to October 24'**
  String get march20ToOct24;

  /// No description provided for @march20ToOct30.
  ///
  /// In en, this message translates to:
  /// **'March 20 to October 30'**
  String get march20ToOct30;

  /// No description provided for @march21ToNovember6.
  ///
  /// In en, this message translates to:
  /// **'March 21 to November 6'**
  String get march21ToNovember6;

  /// No description provided for @march23ToNovember5.
  ///
  /// In en, this message translates to:
  /// **'March 23 to November 5'**
  String get march23ToNovember5;

  /// No description provided for @march25ToDec10_692.
  ///
  /// In en, this message translates to:
  /// **'March 25 to December 10'**
  String get march25ToDec10_692;

  /// No description provided for @march25ToOct15_553.
  ///
  /// In en, this message translates to:
  /// **'March 25 to October 15'**
  String get march25ToOct15_553;

  /// No description provided for @march26ToNov4.
  ///
  /// In en, this message translates to:
  /// **'March 26 to November 4'**
  String get march26ToNov4;

  /// No description provided for @march26ToOct31_679.
  ///
  /// In en, this message translates to:
  /// **'March 26 to October 31'**
  String get march26ToOct31_679;

  /// No description provided for @march28ToOct31ClosedSatSun.
  ///
  /// In en, this message translates to:
  /// **'March 28 to October 31 (closed Saturdays and Sundays)'**
  String get march28ToOct31ClosedSatSun;

  /// No description provided for @march28ToOct31_705.
  ///
  /// In en, this message translates to:
  /// **'March 28 to October 31'**
  String get march28ToOct31_705;

  /// No description provided for @march2ToDec20.
  ///
  /// In en, this message translates to:
  /// **'March 2 to December 20'**
  String get march2ToDec20;

  /// No description provided for @march30ToOct31.
  ///
  /// In en, this message translates to:
  /// **'March 30 to October 31'**
  String get march30ToOct31;

  /// No description provided for @march6ToOct31.
  ///
  /// In en, this message translates to:
  /// **'March 6 to October 31'**
  String get march6ToOct31;

  /// No description provided for @may1ToNovember30_184.
  ///
  /// In en, this message translates to:
  /// **'May 1 to November 30'**
  String get may1ToNovember30_184;

  /// No description provided for @may1ToOct15.
  ///
  /// In en, this message translates to:
  /// **'May 1 to October 15'**
  String get may1ToOct15;

  /// No description provided for @may1ToOctober31_173.
  ///
  /// In en, this message translates to:
  /// **'May 1 to October 31'**
  String get may1ToOctober31_173;

  /// No description provided for @may1ToSeptember30.
  ///
  /// In en, this message translates to:
  /// **'May 1 to September 30'**
  String get may1ToSeptember30;

  /// No description provided for @may3ToOct30.
  ///
  /// In en, this message translates to:
  /// **'May 3 to October 30'**
  String get may3ToOct30;

  ///
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @merlinDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} is the Head of Data and, together with his team, takes care of new hostels, updated prices, changes to the route, and so on.'**
  String merlinDescription(Object name);

  /// No description provided for @microwave.
  ///
  /// In en, this message translates to:
  /// **'Microwave'**
  String get microwave;

  ///
  ///
  /// In en, this message translates to:
  /// **'min/max elev.'**
  String get minMaxElevRouteScreen;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add a Google Maps link, website, or similar to help us locate the accommodation'**
  String get missingAccommodationPlaceholder;

  ///
  ///
  /// In en, this message translates to:
  /// **'Missing accommodation reported'**
  String get missingAccommodationReported;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get mostPopular;

  /// No description provided for @myPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @myStay.
  ///
  /// In en, this message translates to:
  /// **'My stay'**
  String get myStay;

  ///
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameItLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll name it later'**
  String get nameItLater;

  /// No description provided for @namePlanHint.
  ///
  /// In en, this message translates to:
  /// **'My First Camino'**
  String get namePlanHint;

  /// No description provided for @namePlanOptional.
  ///
  /// In en, this message translates to:
  /// **'Name your plan (optional)'**
  String get namePlanOptional;

  /// No description provided for @namePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to call this plan?'**
  String get namePlanTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'New data available'**
  String get newDataAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'Update may include new albergues, booking information, etc.'**
  String get newDataAvailableDescription;

  /// No description provided for @newStagePlanner.
  ///
  /// In en, this message translates to:
  /// **'New: STAGE PLANNER'**
  String get newStagePlanner;

  /// No description provided for @newsAndAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'News & Announcements'**
  String get newsAndAnnouncements;

  /// No description provided for @nextCity.
  ///
  /// In en, this message translates to:
  /// **'Next city'**
  String get nextCity;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @noLocationServices.
  ///
  /// In en, this message translates to:
  /// **'You did not authorize location services. Your location, distance from route, and elevation cannot be shown on the map.'**
  String get noLocationServices;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noReservationCheck.
  ///
  /// In en, this message translates to:
  /// **'No, but possible to confirm availability'**
  String get noReservationCheck;

  ///
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  ///
  ///
  /// In en, this message translates to:
  /// **'No saved accommodation yet.'**
  String get noSavedAccommodationYet;

  /// No description provided for @noSavedPlans.
  ///
  /// In en, this message translates to:
  /// **'Currently, there are no saved plans.\nFeel free to create a new one!'**
  String get noSavedPlans;

  /// No description provided for @noStagePlannedToday.
  ///
  /// In en, this message translates to:
  /// **'You have no Stage planned for today'**
  String get noStagePlannedToday;

  ///
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @notOnRouteName.
  ///
  /// In en, this message translates to:
  /// **'My Ninja App does not believe I am on {routeName}.'**
  String notOnRouteName(Object routeName);

  /// No description provided for @notSameDay.
  ///
  /// In en, this message translates to:
  /// **'Not the same day'**
  String get notSameDay;

  /// No description provided for @notificationPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you about important Camino trail updates — closures, new accommodations, and seasonal news.'**
  String get notificationPromptDescription;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get notificationSettingsDescription;

  /// No description provided for @failedToUpdateSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to update settings. Please try again.'**
  String get failedToUpdateSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in your device settings to receive trail updates and community news.'**
  String get notificationsDisabledDescription;

  /// No description provided for @notificationsDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabledTitle;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not available in this build.'**
  String get notificationsUnavailable;

  /// No description provided for @nov1ToFeb29ExceptDec13To15.
  ///
  /// In en, this message translates to:
  /// **'November 1 to February 29, except December 13 to 15'**
  String get nov1ToFeb29ExceptDec13To15;

  /// No description provided for @nov1ToFeb29_590.
  ///
  /// In en, this message translates to:
  /// **'November 1 to Febuary 29'**
  String get nov1ToFeb29_590;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onlyLowSeason_250.
  ///
  /// In en, this message translates to:
  /// **'Only in low season'**
  String get onlyLowSeason_250;

  /// No description provided for @onlyOffSeason.
  ///
  /// In en, this message translates to:
  /// **'Only off-season'**
  String get onlyOffSeason;

  ///
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong'**
  String get oopsSomethingWentWrong;

  ///
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openSeason.
  ///
  /// In en, this message translates to:
  /// **'Open Season'**
  String get openSeason;

  /// No description provided for @openSeasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Open Season Unknown'**
  String get openSeasonUnknown;

  ///
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @openWhenOthersClosed.
  ///
  /// In en, this message translates to:
  /// **'Only open when all other albergues in Frómista are closed'**
  String get openWhenOthersClosed;

  /// No description provided for @openWhenOthersClosedOctToMay.
  ///
  /// In en, this message translates to:
  /// **'Open when the other Frómista albergues are closed. Open from October to May discontinuously (call to check availability). Closed usually from June to September.'**
  String get openWhenOthersClosedOctToMay;

  ///
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organic;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  ///
  ///
  /// In en, this message translates to:
  /// **'Other channels'**
  String get otherChannels;

  /// No description provided for @oven.
  ///
  /// In en, this message translates to:
  /// **'Oven'**
  String get oven;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @peterDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} is Head of Camino Ninja, and he and his team take care of strategic issues, new app features, and everything else.'**
  String peterDescription(Object name);

  ///
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @photoItem.
  ///
  /// In en, this message translates to:
  /// **'Uploaded photos'**
  String get photoItem;

  ///
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded'**
  String get photoUploaded;

  /// No description provided for @photosAndReviews.
  ///
  /// In en, this message translates to:
  /// **'photos and reviews'**
  String get photosAndReviews;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @planDataIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Data incomplete. Update to the latest data to see this plan.'**
  String get planDataIncomplete;

  /// No description provided for @planDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted the plan'**
  String get planDeletedSuccessfully;

  /// No description provided for @planDetail.
  ///
  /// In en, this message translates to:
  /// **'Plan Detail'**
  String get planDetail;

  /// No description provided for @planFor.
  ///
  /// In en, this message translates to:
  /// **'Plan for'**
  String get planFor;

  /// No description provided for @plannedRoute.
  ///
  /// In en, this message translates to:
  /// **'Planned Route'**
  String get plannedRoute;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @plansImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plans imported successfully!'**
  String get plansImportSuccess;

  /// No description provided for @plansLinkedDescription.
  ///
  /// In en, this message translates to:
  /// **'Plans are now linked to your account. Please sign in to access sharing features and import new Camino Ninja plans.'**
  String get plansLinkedDescription;

  /// No description provided for @platesUtensils.
  ///
  /// In en, this message translates to:
  /// **'Plates & Utensils'**
  String get platesUtensils;

  ///
  ///
  /// In en, this message translates to:
  /// **'Please register to rate your stay'**
  String get pleaseRegisterToReviewYourStay;

  ///
  ///
  /// In en, this message translates to:
  /// **'Please try again later!'**
  String get pleaseTryAgainLater;

  /// No description provided for @postedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted on'**
  String get postedOn;

  ///
  ///
  /// In en, this message translates to:
  /// **'Precise Location is turned off, so your location may be inaccurate.'**
  String get preciseLocationWarning;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  ///
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @privacyCurtains.
  ///
  /// In en, this message translates to:
  /// **'Privacy Curtains'**
  String get privacyCurtains;

  /// No description provided for @privateHomePizza.
  ///
  /// In en, this message translates to:
  /// **'This is not an albergue. It\'s a private home occationally hosting pilgrims. It\'s also a pretty awsome pizza restaurant.'**
  String get privateHomePizza;

  /// No description provided for @privateLockers.
  ///
  /// In en, this message translates to:
  /// **'Private Lockers'**
  String get privateLockers;

  ///
  ///
  /// In en, this message translates to:
  /// **'Proceed as a guest'**
  String get proceedAsAGuest;

  /// No description provided for @proceedWithName.
  ///
  /// In en, this message translates to:
  /// **'Proceed with this name'**
  String get proceedWithName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Provide a rating'**
  String get provideARating;

  /// No description provided for @qrCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'QR Code Invalid'**
  String get qrCodeInvalid;

  /// No description provided for @qrCodeInvalidError.
  ///
  /// In en, this message translates to:
  /// **'QR Code is invalid'**
  String get qrCodeInvalidError;

  /// No description provided for @qrCodeSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'QR Code saved to gallery successfully!'**
  String get qrCodeSaveSuccess;

  /// No description provided for @qrCodeSaved.
  ///
  /// In en, this message translates to:
  /// **'QR Code Saved'**
  String get qrCodeSaved;

  /// No description provided for @quadrupleRoom.
  ///
  /// In en, this message translates to:
  /// **'Quadruple Room'**
  String get quadrupleRoom;

  /// No description provided for @qualityReasonPhotos.
  ///
  /// In en, this message translates to:
  /// **'This helps us to ensure the quality of the photos.'**
  String get qualityReasonPhotos;

  /// No description provided for @qualityReasonReviews.
  ///
  /// In en, this message translates to:
  /// **'This helps us to ensure the quality of the reviews.'**
  String get qualityReasonReviews;

  ///
  ///
  /// In en, this message translates to:
  /// **'Rate this accommodation'**
  String get rateThisAccommodation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @recommendLogin.
  ///
  /// In en, this message translates to:
  /// **'We recommend to log in / create an account.'**
  String get recommendLogin;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @refrigerator.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get refrigerator;

  /// No description provided for @registerForPhotos.
  ///
  /// In en, this message translates to:
  /// **'Please register to upload photos'**
  String get registerForPhotos;

  /// No description provided for @registerForReview.
  ///
  /// In en, this message translates to:
  /// **'Please register to write a review'**
  String get registerForReview;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindMeLater;

  /// No description provided for @removeStay.
  ///
  /// In en, this message translates to:
  /// **'Remove stay'**
  String get removeStay;

  /// No description provided for @rentWholeUntilMarch2022.
  ///
  /// In en, this message translates to:
  /// **'Until March 2022 it is only possible to rent the whole albergue for 120 a night (10 people)'**
  String get rentWholeUntilMarch2022;

  ///
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportAnIssue;

  ///
  ///
  /// In en, this message translates to:
  /// **'Report missing accommodation'**
  String get reportMissingAccommodation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Help us out by adding its details—like a Google Maps link or location info.'**
  String get reportMissingAlbergueBottomSheetDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Don’t see an accommodation you know in this city?'**
  String get reportMissingAlbergueBottomSheetTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Thank you for helping us keep Camino Ninja up to date.'**
  String get reportMissingAlbergueMessage;

  /// No description provided for @reportTechnicalIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Technical Issue'**
  String get reportTechnicalIssue;

  ///
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @reservation60Plus.
  ///
  /// In en, this message translates to:
  /// **'Reservation only possible for pilgrims who are 60 years or older'**
  String get reservation60Plus;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  ///
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  ///
  ///
  /// In en, this message translates to:
  /// **'Return to all locations'**
  String get returnToAllLocations;

  ///
  ///
  /// In en, this message translates to:
  /// **'Other pilgrims would like to know!'**
  String get reviewAlbergueBottomSheetDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'How would you rate the overall experience with this place?'**
  String get reviewAlbergueBottomSheetTitle;

  /// No description provided for @reviewApp.
  ///
  /// In en, this message translates to:
  /// **'Review Camino Ninja App'**
  String get reviewApp;

  /// No description provided for @reviewItem.
  ///
  /// In en, this message translates to:
  /// **'Accommodation reviews'**
  String get reviewItem;

  ///
  ///
  /// In en, this message translates to:
  /// **'Posting with an account makes reviews more genuine and trustworthy for everyone in the community.'**
  String get reviewRequiredLoginDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @reviewsIHaveWritten.
  ///
  /// In en, this message translates to:
  /// **'Reviews I have written'**
  String get reviewsIHaveWritten;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'Route Summary'**
  String get routeSummary;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChange.
  ///
  /// In en, this message translates to:
  /// **'Save change'**
  String get saveChange;

  /// No description provided for @saveQrCode.
  ///
  /// In en, this message translates to:
  /// **'Save QR Code'**
  String get saveQrCode;

  /// No description provided for @savedAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Saved accommodation'**
  String get savedAccommodation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Saved accommodations'**
  String get savedAccommodations;

  /// No description provided for @savedOn.
  ///
  /// In en, this message translates to:
  /// **'Saved on'**
  String get savedOn;

  /// No description provided for @savedStaysNote.
  ///
  /// In en, this message translates to:
  /// **'My saved stays are here'**
  String get savedStaysNote;

  /// No description provided for @scanHere.
  ///
  /// In en, this message translates to:
  /// **'Scan here'**
  String get scanHere;

  /// No description provided for @scanOrOpenPhoto.
  ///
  /// In en, this message translates to:
  /// **'Scan (or open as a photo)\nwith the Camino Ninja app'**
  String get scanOrOpenPhoto;

  /// No description provided for @scanOrUploadQr.
  ///
  /// In en, this message translates to:
  /// **'Scan or Upload QR Code'**
  String get scanOrUploadQr;

  /// No description provided for @schedulingConflict.
  ///
  /// In en, this message translates to:
  /// **'You have a scheduling conflict on this date'**
  String get schedulingConflict;

  ///
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @secondMostPopular.
  ///
  /// In en, this message translates to:
  /// **'2nd most popular'**
  String get secondMostPopular;

  /// No description provided for @seeMyComment.
  ///
  /// In en, this message translates to:
  /// **'See my comment'**
  String get seeMyComment;

  ///
  ///
  /// In en, this message translates to:
  /// **'See them on the map'**
  String get seeThemOnTheMap;

  /// No description provided for @selectCityCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Select city from current location'**
  String get selectCityCurrentLocation;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select a start date'**
  String get selectStartDate;

  /// No description provided for @selectDestinationCity.
  ///
  /// In en, this message translates to:
  /// **'Select your destination city'**
  String get selectDestinationCity;

  /// No description provided for @selectFromTheList.
  ///
  /// In en, this message translates to:
  /// **'Select from the list'**
  String get selectFromTheList;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Just a friendly reminder that some languages might be translated by AI.'**
  String get selectLanguageDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// No description provided for @selectOrSpecify.
  ///
  /// In en, this message translates to:
  /// **'Select or specify'**
  String get selectOrSpecify;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// No description provided for @selectPlansToShare.
  ///
  /// In en, this message translates to:
  /// **'Select a plans to share'**
  String get selectPlansToShare;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select Route'**
  String get selectRoute;

  /// No description provided for @selectRouteForMap.
  ///
  /// In en, this message translates to:
  /// **'Please select a route to show on the map.'**
  String get selectRouteForMap;

  /// No description provided for @selectRoute_431.
  ///
  /// In en, this message translates to:
  /// **'Select route'**
  String get selectRoute_431;

  /// No description provided for @selectStartingCity.
  ///
  /// In en, this message translates to:
  /// **'Select your starting city'**
  String get selectStartingCity;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// No description provided for @selectedRoute.
  ///
  /// In en, this message translates to:
  /// **'the selected route'**
  String get selectedRoute;

  /// No description provided for @sendLuggage.
  ///
  /// In en, this message translates to:
  /// **'Send luggage to Santiago'**
  String get sendLuggage;

  /// Shown when the user's authentication session expires and they are logged out
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @setStartingDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Set starting date (optional)'**
  String get setStartingDateOptional;

  ///
  ///
  /// In en, this message translates to:
  /// **'Shake Ninja'**
  String get shakeNinja;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareMessageSocial.
  ///
  /// In en, this message translates to:
  /// **'Share in message or social media'**
  String get shareMessageSocial;

  /// No description provided for @sharePlan.
  ///
  /// In en, this message translates to:
  /// **'Share Plan'**
  String get sharePlan;

  ///
  ///
  /// In en, this message translates to:
  /// **'Share your photos of this accommodation'**
  String get shareYourPhotosOfThisAccommodation;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @showTranslated.
  ///
  /// In en, this message translates to:
  /// **'Show translated'**
  String get showTranslated;

  /// No description provided for @signInSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Sign up'**
  String get signInSignUp;

  /// No description provided for @signInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your plans across devices'**
  String get signInToSync;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @singleRoom.
  ///
  /// In en, this message translates to:
  /// **'Single Room'**
  String get singleRoom;

  /// No description provided for @somethingNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Something not working?'**
  String get somethingNotWorking;

  /// No description provided for @spinDryer.
  ///
  /// In en, this message translates to:
  /// **'Spin Dryer'**
  String get spinDryer;

  /// No description provided for @stageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted the stage'**
  String get stageDeletedSuccessfully;

  /// No description provided for @stageDistance.
  ///
  /// In en, this message translates to:
  /// **'Stage Distance'**
  String get stageDistance;

  /// No description provided for @stageElevation.
  ///
  /// In en, this message translates to:
  /// **'Stage Elevation'**
  String get stageElevation;

  /// No description provided for @stagePlannerDescription.
  ///
  /// In en, this message translates to:
  /// **'From now on you can PLAN your full camino with Ninja, planning as many days ahead as you like.\n\nThis is the first version of the PLAN feature. If you have an idea how we can improve this new feature, please send the feedback by shaking your phone, or use the contact email in the MORE section.'**
  String get stagePlannerDescription;

  /// No description provided for @stagePlural.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagePlural;

  /// No description provided for @stageScheduledPastDate.
  ///
  /// In en, this message translates to:
  /// **'This stage is scheduled for a past date'**
  String get stageScheduledPastDate;

  /// No description provided for @stageSingular.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stageSingular;

  /// No description provided for @stageToDeleteDetails.
  ///
  /// In en, this message translates to:
  /// **'The stage on'**
  String get stageToDeleteDetails;

  /// No description provided for @startHereToday.
  ///
  /// In en, this message translates to:
  /// **'I\'ll start here today'**
  String get startHereToday;

  /// No description provided for @startOfStage.
  ///
  /// In en, this message translates to:
  /// **'Start of stage'**
  String get startOfStage;

  /// No description provided for @startingDate.
  ///
  /// In en, this message translates to:
  /// **'Starting date'**
  String get startingDate;

  /// No description provided for @stayInTheLoop.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get stayInTheLoop;

  ///
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @suspended_537.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended_537;

  /// No description provided for @swimmingPool.
  ///
  /// In en, this message translates to:
  /// **'Swimming pool'**
  String get swimmingPool;

  ///
  ///
  /// In en, this message translates to:
  /// **'Switch Unit'**
  String get switchUnit;

  ///
  ///
  /// In en, this message translates to:
  /// **'Switch Unit (km/miles)'**
  String get switchUnitKmMiles;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncFailureDescription.
  ///
  /// In en, this message translates to:
  /// **'Could not sync your plans. Please try again later.'**
  String get syncFailureDescription;

  /// No description provided for @syncFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailureTitle;

  /// No description provided for @syncSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Your plans have been synced successfully.'**
  String get syncSuccessDescription;

  /// No description provided for @syncSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans synced'**
  String get syncSuccessTitle;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced!'**
  String get synced;

  /// No description provided for @syncedCopy.
  ///
  /// In en, this message translates to:
  /// **'Synced copy'**
  String get syncedCopy;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  ///
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  ///
  ///
  /// In en, this message translates to:
  /// **'Tap to see the map'**
  String get tapToSeeTheMap;

  /// No description provided for @taxiBoat.
  ///
  /// In en, this message translates to:
  /// **'If you want to walk by the coast in Spain along Caminho Português da Costa (Senda Litoral) you can take the taxi boat Taxi-Mar (+351 915 955 827) from the old ferry dock'**
  String get taxiBoat;

  /// No description provided for @taxiBoatPontecesures.
  ///
  /// In en, this message translates to:
  /// **'Amare Turismo Náutico have taxi-boats sailing from Vilanova de Arousa to Pontecesures all year round for 25 euros per person. Minimum 8 persons and maximum 12. Reservations by phone / WhatsApp: +34 650 41 03 22'**
  String get taxiBoatPontecesures;

  ///
  ///
  /// In en, this message translates to:
  /// **'Tell us more about the issue'**
  String get tellUsMoreAboutTheIssue;

  ///
  ///
  /// In en, this message translates to:
  /// **'Tell your friend about this place'**
  String get tellYourFriendAboutThisPlace;

  /// No description provided for @tentDonation.
  ///
  /// In en, this message translates to:
  /// **'You might want to ask if you can put your tent up in the garden for a donation and help volunteering a little. Donations are welcome for the restoration of the abbey as well.'**
  String get tentDonation;

  /// No description provided for @tentsMattressSheet.
  ///
  /// In en, this message translates to:
  /// **'Tents are provided for sleeping with a mattress and bed sheet'**
  String get tentsMattressSheet;

  ///
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  ///
  ///
  /// In en, this message translates to:
  /// **'Themes Available'**
  String get themeAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'There is no accommodation in this location.'**
  String get thereIsNoAccommodationInThisLocation;

  /// No description provided for @thirdMostPopular.
  ///
  /// In en, this message translates to:
  /// **'3rd most popular'**
  String get thirdMostPopular;

  ///
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  ///
  ///
  /// In en, this message translates to:
  /// **'to report a problem with the app'**
  String get toReportAProblemWithTheApp;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @translated.
  ///
  /// In en, this message translates to:
  /// **'Translated'**
  String get translated;

  /// No description provided for @travelerStats.
  ///
  /// In en, this message translates to:
  /// **'{percent} of travelers starting in {startCity} end up in {endCity}.'**
  String travelerStats(Object endCity, Object percent, Object startCity);

  /// No description provided for @tripleRoom.
  ///
  /// In en, this message translates to:
  /// **'Triple Room'**
  String get tripleRoom;

  ///
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms.'**
  String get tryAdjustingYourSearchTerms;

  /// No description provided for @tumbleDryer.
  ///
  /// In en, this message translates to:
  /// **'Tumble Dryer'**
  String get tumbleDryer;

  /// No description provided for @tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tv;

  /// No description provided for @twoWeeksBeforeEasterToNov15.
  ///
  /// In en, this message translates to:
  /// **'Two weeks before Easter to November 15'**
  String get twoWeeksBeforeEasterToNov15;

  /// No description provided for @unnamedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unnamed plan'**
  String get unnamedPlan;

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'You’re on an old app version. Update today to keep your login active and get our newest trail maps—otherwise, you’ll miss out on all the latest features.'**
  String get updateDescription;

  ///
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update to stay on track!'**
  String get updateTitle;

  /// No description provided for @updateToUseQR.
  ///
  /// In en, this message translates to:
  /// **'To use this QR code, please update your app to version {versionName} or higher.'**
  String updateToUseQR(Object versionName);

  /// No description provided for @update_360.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_360;

  /// Message shown when updating data
  ///
  /// In en, this message translates to:
  /// **'Updating the latest data'**
  String get updatingMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Upload was unsuccessful due to cancellation.'**
  String get uploadFailDueToCancellation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Or upload QR code\nfrom your gallery'**
  String get uploadFromGallery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Upload images'**
  String get uploadImages;

  ///
  ///
  /// In en, this message translates to:
  /// **'We’re reviewing your photos to keep the app respectful and high-quality.'**
  String get uploadPhotoSuccessMessage;

  /// No description provided for @uploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload photos'**
  String get uploadPhotos;

  ///
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @useWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'You can still use Camino Ninja without being logged in - and this will never change.'**
  String get useWithoutLogin;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @veganOption.
  ///
  /// In en, this message translates to:
  /// **'Vegan Option'**
  String get veganOption;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegetarianOption.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian Option'**
  String get vegetarianOption;

  /// No description provided for @viewDetail.
  ///
  /// In en, this message translates to:
  /// **'View detail'**
  String get viewDetail;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @viewPlan.
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get viewPlan;

  ///
  ///
  /// In en, this message translates to:
  /// **'You need to be online to load albergue reviews.'**
  String get warningOnlineToLoadAlbergueReviews;

  ///
  ///
  /// In en, this message translates to:
  /// **'Tap the stars to rate before submitting.'**
  String get warningRateBeforeSubmitReview;

  /// No description provided for @washingMachine.
  ///
  /// In en, this message translates to:
  /// **'Washing Machine'**
  String get washingMachine;

  /// No description provided for @waterBoiler.
  ///
  /// In en, this message translates to:
  /// **'Water Boiler'**
  String get waterBoiler;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  ///
  ///
  /// In en, this message translates to:
  /// **'What\'s in here'**
  String get whatInHere;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @willBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'will be deleted'**
  String get willBeDeleted;

  /// No description provided for @winterCheckIn1400To2000.
  ///
  /// In en, this message translates to:
  /// **'In winter the check-in time is from 14:00-20:00'**
  String get winterCheckIn1400To2000;

  /// No description provided for @xuntaReservation.
  ///
  /// In en, this message translates to:
  /// **'Yes, required. Xunta de Galicia albergues require online reservation at the latest the same day before 13:00 / 01:00 pm.'**
  String get xuntaReservation;

  /// No description provided for @xuntaWifi.
  ///
  /// In en, this message translates to:
  /// **'All Xunta albergues: Wi-Fi may or may not work depending on your country and service provider as a text message is needed to log on to the wi-fi.'**
  String get xuntaWifi;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yes24Hours.
  ///
  /// In en, this message translates to:
  /// **'Yes, 24 hours in advance'**
  String get yes24Hours;

  /// No description provided for @yes5DaysWebsite.
  ///
  /// In en, this message translates to:
  /// **'Yes, 5 days in advance on the website'**
  String get yes5DaysWebsite;

  /// No description provided for @yesEmailPrepayment.
  ///
  /// In en, this message translates to:
  /// **'Yes, by email and with prepayment'**
  String get yesEmailPrepayment;

  /// No description provided for @yesExceptAugust.
  ///
  /// In en, this message translates to:
  /// **'Yes, exept in August'**
  String get yesExceptAugust;

  /// No description provided for @yesExceptSummer.
  ///
  /// In en, this message translates to:
  /// **'Yes, except in summer'**
  String get yesExceptSummer;

  /// No description provided for @yesOneDayAdvance.
  ///
  /// In en, this message translates to:
  /// **'Yes, but at least one day in advance.'**
  String get yesOneDayAdvance;

  /// No description provided for @yesOnline.
  ///
  /// In en, this message translates to:
  /// **'Yes, only online'**
  String get yesOnline;

  /// No description provided for @yesPrivateRoomOnly.
  ///
  /// In en, this message translates to:
  /// **'Yes, for private room only'**
  String get yesPrivateRoomOnly;

  /// No description provided for @yesRecommendedChristmas.
  ///
  /// In en, this message translates to:
  /// **'Yes, recommended around Christmas'**
  String get yesRecommendedChristmas;

  /// No description provided for @yesRecommendedWinter.
  ///
  /// In en, this message translates to:
  /// **'Yes, recommended in winter'**
  String get yesRecommendedWinter;

  /// No description provided for @yesRecommended_246.
  ///
  /// In en, this message translates to:
  /// **'Yes, recommended'**
  String get yesRecommended_246;

  /// No description provided for @yesRecommended_249.
  ///
  /// In en, this message translates to:
  /// **'Yes, recommended'**
  String get yesRecommended_249;

  /// No description provided for @yesRequired.
  ///
  /// In en, this message translates to:
  /// **'Yes (required)'**
  String get yesRequired;

  /// No description provided for @yesRequiredFebMarch.
  ///
  /// In en, this message translates to:
  /// **'Yes, required in February and March'**
  String get yesRequiredFebMarch;

  /// No description provided for @yesRequiredWinter.
  ///
  /// In en, this message translates to:
  /// **'Yes, required in winter'**
  String get yesRequiredWinter;

  /// No description provided for @yesRequired_257.
  ///
  /// In en, this message translates to:
  /// **'Yes, required'**
  String get yesRequired_257;

  /// No description provided for @yesSameDay.
  ///
  /// In en, this message translates to:
  /// **'Yes, same day'**
  String get yesSameDay;

  ///
  ///
  /// In en, this message translates to:
  /// **'You are {distance} km from {cityName}, the location closest to me on '**
  String youAreDistanceFromCity(Object cityName, Object distance);

  ///
  ///
  /// In en, this message translates to:
  /// **'You\'are here'**
  String get youAreHere;

  ///
  ///
  /// In en, this message translates to:
  /// **'You’re too far'**
  String get youAreTooFar;

  ///
  ///
  /// In en, this message translates to:
  /// **'Your stages are not connected'**
  String get stagesNotConnected;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add city in-between now'**
  String get addCityInBetween;

  /// Snack bar confirmation after copying the app version to clipboard
  ///
  /// In en, this message translates to:
  /// **'Version copied'**
  String get versionCopied;

  /// Action to mark all notifications or announcements as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @scanWithVersion.
  ///
  /// In en, this message translates to:
  /// **'Scan with Camino Ninja {version} or newer.'**
  String scanWithVersion(String version);

  /// Placeholder text shown on the plan-detail Notes card when the stage has no note yet.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addANote;

  /// Title on the Buy Me a Coffee banner on the More tab. {brand} is the Camino Ninja brand mascot name and is rendered in the brand color. Translators may move {brand} where natural in their language; the substituted text 'Ninja' stays in English.
  ///
  /// In en, this message translates to:
  /// **'Buy {brand} a coffee'**
  String buyNinjaACoffee(String brand);

  /// Button label in the stage-note bottom sheet that clears the existing note.
  ///
  /// In en, this message translates to:
  /// **'Clear note'**
  String get clearNote;

  /// Label shown above the optional Notes text field in the Add/Edit Stage screen.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Subtitle/helper text in the stage-note bottom sheet explaining that notes are private.
  ///
  /// In en, this message translates to:
  /// **'Add a personal note for this stage — directions, reminders, vibes. Only you see this.'**
  String get stageNoteDescription;

  /// Title shown at the top of the bottom sheet where the user edits a stage note.
  ///
  /// In en, this message translates to:
  /// **'Stage note'**
  String get stageNoteTitle;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Bold leading word of the login reminder banner. Translators may swap this with the natural call-to-action verb in their language; pair with loginReminderBannerCallToActionRest.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get loginReminderBannerCallToAction;

  /// Remainder of the login reminder banner copy after the bold call-to-action word. Begins with a leading space so it concatenates after loginReminderBannerCallToAction.
  ///
  /// In en, this message translates to:
  /// **' to sign in and back up your {stageCount}-stage plan'**
  String loginReminderBannerCallToActionRest(int stageCount);

  /// Accessibility label for the dismiss (X) button on the login reminder banner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss login reminder'**
  String get loginReminderBannerDismissLabel;

  /// Title shown at the top of the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Lose Your Progress!'**
  String get loginReminderSheetTitle;

  /// Subtitle shown below the title in the login reminder bottomsheet, introducing the feature list.
  ///
  /// In en, this message translates to:
  /// **'Looks like you have a lot planned. Log in now to protect your data and unlock more features:'**
  String get loginReminderSheetSubtitle;

  /// Title of the Cloud Sync feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get loginReminderSheetCloudSyncTitle;

  /// Description of the Cloud Sync feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Access stays and plans on any device.'**
  String get loginReminderSheetCloudSyncDescription;

  /// Title of the Community feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get loginReminderSheetCommunityTitle;

  /// Description of the Community feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Review places and share plans with pals.'**
  String get loginReminderSheetCommunityDescription;

  /// Title of the Peace of Mind feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Peace of Mind'**
  String get loginReminderSheetPeaceOfMindTitle;

  /// Description of the Peace of Mind feature row in the login reminder bottomsheet.
  ///
  /// In en, this message translates to:
  /// **'Your plans stay safe, no matter what.'**
  String get loginReminderSheetPeaceOfMindDescription;

  /// Title shown on the QR scanner permission explainer when camera access is required.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermissionTitle;

  /// Body text shown on the QR scanner permission explainer when camera access is required.
  ///
  /// In en, this message translates to:
  /// **'We need camera access to scan QR codes. You can still upload a QR image from your gallery without it.'**
  String get cameraPermissionBody;

  /// Title for the bug-report opt-in checkbox that attaches an anonymized stage planner DB snapshot
  ///
  /// In en, this message translates to:
  /// **'Share My Plans data to help us troubleshoot'**
  String get includeDbDumpTitle;

  /// Subtitle/description under the bug-report DB-attachment checkbox; informs the user that PII is scrubbed
  ///
  /// In en, this message translates to:
  /// **'Plan names and notes are excluded for your privacy.'**
  String get includeDbDumpSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cs',
    'da',
    'de',
    'en',
    'es',
    'fr',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'uk',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
