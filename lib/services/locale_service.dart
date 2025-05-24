import 'package:flutter/material.dart';

class LocaleService extends ChangeNotifier {
  static const Locale _defaultLocale = Locale('ru');
  
  Locale _locale = _defaultLocale;
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
  
  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('ky'),
  ];
  
  static LocaleService? _instance;
  
  static LocaleService get instance {
    _instance ??= LocaleService();
    return _instance!;
  }
}
