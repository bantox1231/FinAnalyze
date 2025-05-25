import 'package:flutter/material.dart';

class LocaleService extends ChangeNotifier {
  static const Locale _defaultLocale = Locale('ru');
  
  Locale _locale = _defaultLocale;
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    print('LocaleService.setLocale вызван с: $locale');
    print('Текущий _locale: $_locale');
    if (_locale != locale) {
      _locale = locale;
      print('Язык изменен на: $_locale');
      notifyListeners();
      print('notifyListeners() вызван');
    } else {
      print('Язык не изменился, остается: $_locale');
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
