import 'package:flutter/foundation.dart';
// Условный импорт для не-веб платформ
import 'platform_io.dart' if (dart.library.html) 'platform_web.dart' as platform;

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  
  static bool get isAndroid {
    if (kIsWeb) return false;
    return platform.isAndroid;
  }
  
  static bool get isIOS {
    if (kIsWeb) return false;
    return platform.isIOS;
  }
  
  static bool get isEmulator {
    if (!isAndroid) return false;
    return platform.isEmulator;
  }
} 