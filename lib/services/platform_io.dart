import 'dart:io' show Platform;

bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
bool get isEmulator => 
    Platform.isAndroid && 
    (Platform.environment['ANDROID_EMULATOR'] == '1' ||
     Platform.environment['ANDROID_SDK_ROOT'] != null); 