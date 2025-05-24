import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/bank_report_pdf.dart';
import '../services/api_service.dart';
import 'bank_report_screen.dart';
import '../models/bank_report.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfReportsScreen extends StatefulWidget {
  const PdfReportsScreen({super.key});

  @override
  State<PdfReportsScreen> createState() => _PdfReportsScreenState();
}

class _PdfReportsScreenState extends State<PdfReportsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  int? _selectedYear;
  int? _selectedMonth;
  Set<int> _selectedBankIds = {};
  List<BankReportPdf>? _reports;
  Set<String> _downloadedReportUrls = {};
  List<XFile> _downloadedFiles = [];

  final List<int> _years = List.generate(DateTime.now().year - 2010 + 1,
          (index) => 2010 + index);

  final Map<int, String> _months = {
    1: 'Январь',
    2: 'Февраль',
    3: 'Март',
    4: 'Апрель',
    5: 'Май',
    6: 'Июнь',
    7: 'Июль',
    8: 'Август',
    9: 'Сентябрь',
    10: 'Октябрь',
    11: 'Ноябрь',
    12: 'Декабрь',
  };

  Future<void> _loadReports() async {
    if (_selectedYear == null || _selectedMonth == null) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
      _reports = null;
      _downloadedFiles.clear();
      _downloadedReportUrls.clear();
    });

    try {
      String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
      String formattedDate = '${_selectedYear}-$formattedMonth-01';

      final reports = await _apiService.fetchBankPdfReports(
        startDate: formattedDate,
        selectedBankIds: _selectedBankIds.isEmpty ? null : _selectedBankIds.toList(),
      );

      if (mounted) {
        setState(() {
          _reports = reports;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadReport(BankReportPdf report) async {
    try {
      final url = Uri.parse(report.reportUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при открытии отчета: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeReports() async {
    if (_reports == null || _reports!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет отчетов для анализа'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
      });

      // Получаем дату из первого отчета
      final firstReport = _reports!.first;
      final reportDate = firstReport.reportDate;
      String formattedDate = '${reportDate.year}-${reportDate.month.toString().padLeft(2, '0')}-${reportDate.day.toString().padLeft(2, '0')}';

      // Получаем результаты анализа
      final result = await _apiService.fetchBankReport(
        startDate: formattedDate,
        selectedBankIds: _selectedBankIds.isEmpty ? null : _selectedBankIds.toList(),
      );

      if (mounted) {
        final reportResponse = BankReportResponse.fromJson(result);
        if (reportResponse.analyses.isEmpty) {
          throw Exception('Сервер не вернул данные анализа');
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BankReportScreen(
              reportResponse: reportResponse,
              comparativeAnalysis: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при анализе отчетов: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBankSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите банки',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...ApiService.bankIds.entries.map((entry) {
              final isSelected = _selectedBankIds.contains(entry.value);
              return FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedBankIds.add(entry.value);
                    } else {
                      _selectedBankIds.remove(entry.value);
                    }
                  });
                },
              );
            }),
            FilterChip(
              label: const Text('Все банки'),
              selected: _selectedBankIds.isEmpty,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBankIds.clear();
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isError) ...[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Произошла ошибка:\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Выберите период',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Год',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedYear,
                  items: _years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Месяц',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedMonth,
                  items: _months.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBankSelectionSection(),
          const SizedBox(height: 20),
          if (_selectedYear != null && _selectedMonth != null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadReports,
                icon: const Icon(Icons.search),
                label: const Text('Найти отчеты'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          if (_reports != null && _reports!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Найденные отчеты:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeReports,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Проанализировать отчеты'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reports!.length,
              itemBuilder: (context, index) {
                final report = _reports![index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(report.bankName),
                    subtitle: Text(report.reportTitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _downloadReport(report),
                      tooltip: 'Открыть отчет',
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
} 