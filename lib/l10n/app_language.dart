import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum AppLanguage {
  es('es', 'Spanish (Español)'),
  en('en', 'English'),
  de('de', 'German (Deutsch)'),
  it('it', 'Italian (Italiano)'),
  pt('pt', 'Portuguese (Português)'),
  fr('fr', 'French (Français)'),
  ko('ko', 'Korean (한국어)'),
  pl('pl', 'Polish (Polski)'),
  nl('nl', 'Dutch (Nederlands)'),
  cs('cs', 'Czech (Čeština)'),
  zh('zh', 'Simplified Chinese (简体中文)'),
  da('da', 'Danish (Dansk)'),
  id('id', 'Indonesian (Bahasa Indonesia)'),
  ja('ja', 'Japanese (日本語)'),
  hu('hu', 'Hungarian (Magyar)'),
  ro('ro', 'Romanian (Română)'),
  ru('ru', 'Russian (Русский)'),
  uk('uk', 'Ukrainian (Українська)'),
  hr('hr', 'Croatian (Hrvatski)');

  const AppLanguage(this.code, this.title);

  final String code;
  final String title;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.en,
    );
  }

  static List<String> get codes =>
      AppLanguage.values.map((e) => e.code).toList();

  static List<String> get titles =>
      AppLanguage.values.map((e) => e.title).toList();

  Widget getFlag() {
    final isSupported = AppLanguage.values.any((e) => e.code == code);
    if (isSupported) {
      return SvgPicture.asset(
        'assets/flags/$code.svg',
        width: 22,
      );
    }
    return const SizedBox.shrink();
  }
}
