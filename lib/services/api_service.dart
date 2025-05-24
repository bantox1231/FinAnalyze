import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_selector/file_selector.dart';
import '../models/bank_report_pdf.dart';
import 'api_service_mobile.dart' if (dart.library.html) 'api_service_web.dart';

class ApiService {
  // Используем только локальную сеть для всех платформ
  static const String baseUrl = 'http://192.168.169.60:8000';

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
        'lang': 'ky',
      };

      if (selectedBankIds != null && selectedBankIds.isNotEmpty) {
        queryParameters['bank_ids'] = selectedBankIds.join(',');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '/analyze',
        queryParameters: queryParameters,
      );

      print('Отправка запроса на: $uri');

      final response = await http.get(uri);

      print('Получен ответ со статусом: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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

  Future<Map<String, dynamic>> analyzePdfFiles(List<XFile> files) async {
    try {
      final uri = Uri.parse('$baseUrl/analyze_by_pdf');
      var request = http.MultipartRequest('POST', uri);
      
      for (var file in files) {
        final multipartFile = await PlatformService.createMultipartFile(file);
        request.files.add(multipartFile);
      }

      print('Отправка PDF файлов на: ${uri}');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Получен ответ со статусом: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        print('Тело ответа с ошибкой: $responseBody');
        throw Exception('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      print('Произошла ошибка при отправке PDF: $e');
      throw Exception('Ошибка при отправке PDF: $e');
    }
  }

  Future<List<BankReportPdf>> fetchBankPdfReports({
    required String startDate,
    List<int>? selectedBankIds,
  }) async {
    try {
      final queryParameters = {
        'start_date': startDate,
        'report_type': 'monthly',
        'lang': 'ky',
      };

      if (selectedBankIds != null && selectedBankIds.isNotEmpty) {
        queryParameters['bank_ids'] = selectedBankIds.join(',');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '/reports',
        queryParameters: queryParameters,
      );

      print('Отправка запроса на: $uri');

      final response = await http.get(uri);

      print('Получен ответ со статусом: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final reports = jsonResponse.map((json) => BankReportPdf.fromJson(json)).toList();
        
        // Фильтруем отчеты Optima Bank, оставляя только те, что опубликованы 1-го числа
        return reports.where((report) {
          if (report.bankName.contains('Optima')) {
            return report.reportTitle.contains('(published 01.');
          }
          return true;
        }).toList();
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