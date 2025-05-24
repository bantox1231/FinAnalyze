import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/bank_report.dart';
import 'package:file_selector/file_selector.dart';

import 'bank_report_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  int? _selectedYear;
  int? _selectedMonth;
  Set<int> _selectedBankIds = {};
  BankReportResponse? _reportResponse;
  Map<String, dynamic>? _comparativeAnalysis;
  List<XFile>? _selectedFiles;

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

  Future<void> _loadReport() async {
    if (_selectedYear == null || _selectedMonth == null) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
      _reportResponse = null;
      _comparativeAnalysis = null;
    });

    try {
      String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
      String formattedDate = '${_selectedYear}-$formattedMonth-01';
      
      final response = await _apiService.fetchBankReport(
        startDate: formattedDate,
        selectedBankIds: _selectedBankIds.isEmpty ? null : _selectedBankIds.toList(),
      );
      
      if (mounted) {
        final reportResponse = BankReportResponse.fromJson(response);
        if (reportResponse.analyses.isEmpty) {
          throw Exception('Сервер не вернул данные анализа');
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BankReportScreen(
              reportResponse: reportResponse,
              comparativeAnalysis: response,
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
            content: Text('Ошибка при загрузке отчета: $e'),
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

  Future<void> _pickFiles() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'PDF files',
        extensions: ['pdf'],
      );

      final files = await openFiles(acceptedTypeGroups: [typeGroup]);
      if (files.isNotEmpty) {
        setState(() {
          _selectedFiles = files;
          _reportResponse = null;
          _comparativeAnalysis = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе файлов: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzePdfFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
      });

      final result = await _apiService.analyzePdfFiles(_selectedFiles!);

      if (mounted) {
        setState(() {
          _reportResponse = BankReportResponse.fromJson(result);
          _comparativeAnalysis = result;
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

  void _removeFile(int index) {
    setState(() {
      _selectedFiles!.removeAt(index);
      if (_selectedFiles!.isEmpty) {
        _selectedFiles = null;
      }
    });
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

  Widget _buildFileSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Или загрузите PDF файлы',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickFiles,
            icon: const Icon(Icons.upload_file),
            label: const Text('Выбрать PDF файлы'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (_selectedFiles != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Выбранные файлы:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles!.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles![index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(file.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeFile(index),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzePdfFiles,
              icon: const Icon(Icons.analytics),
              label: const Text('Провести анализ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisResults() {
    if (_reportResponse == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Результаты анализа',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Здесь добавьте виджеты для отображения результатов анализа
        // используя данные из _reportResponse и _comparativeAnalysis
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
                onPressed: _isLoading ? null : _loadReport,
                icon: const Icon(Icons.search),
                label: const Text('Получить отчет'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildFileSelectionSection(),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          _buildAnalysisResults(),
        ],
      ),
    );
  }
} 