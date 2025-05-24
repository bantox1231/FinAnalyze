import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'platform_helper.dart';

class ApiService {
  // Используем IP вашего компьютера в локальной сети для реальных устройств
  static const String _localNetworkUrl = 'http://192.168.98.60:8000';
  static const String _emulatorUrl = 'http://10.0.2.2:8000';
  static const String _webUrl = 'http://localhost:8000';

  static String get baseUrl {
    if (PlatformHelper.isWeb) {
      print('Используется веб-платформа');
      return _webUrl;
    }
    
    if (PlatformHelper.isEmulator) {
      print('Используется Android эмулятор');
      return _emulatorUrl;
    }
    
    print('Используется реальное устройство');
    return _localNetworkUrl;
  }

  static const Map<String, int> bankIds = {
    'KICB': 1,
    'Optima': 2,
    'DemirBank': 3,
    'MBank': 4,
    'RSK': 5,
  };

  Future<Map<String, dynamic>> fetchBankReport({
    required String startDate,
    List<int>? selectedBankIds,
  }) async {
    try {
      final queryParameters = {
        'start_date': startDate,
        'report_type': 'monthly',
      };

      if (selectedBankIds != null && selectedBankIds.isNotEmpty) {
        queryParameters['bank_id'] = selectedBankIds.join(',');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '/analyze',
        queryParameters: queryParameters,
      );

      print('Отправка запроса на: $uri');
      print('Используемый baseUrl: ${baseUrl}');

      final response = await http.get(uri);

      print('Получен ответ со статусом: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Структура ответа: ${jsonResponse.keys}');
        print('Содержимое comparative_analysis: ${jsonResponse['comparative_analysis']}');
        
        // Проверяем структуру данных
        if (jsonResponse['comparative_analysis'] == null) {
          print('Внимание: comparative_analysis отсутствует в ответе');
        }
        
        return jsonResponse;
      } else {
        print('Тело ответа с ошибкой: ${response.body}');
        throw Exception('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      print('Произошла ошибка: $e');
      throw Exception('Ошибка сети: $e');
    }
  }
} 