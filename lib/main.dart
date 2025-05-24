import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/bank_report.dart';
import 'screens/bank_report_screen.dart';
import 'services/api_service.dart';
import 'services/locale_service.dart';
import 'package:file_selector/file_selector.dart';
import 'screens/pdf_reports_screen.dart';
import 'screens/analysis_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'FinAnalyze',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleService.supportedLocales,
          locale: LocaleService.instance.locale,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const AnalysisScreen(),
    const PdfReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.russian),
                leading: Radio<Locale>(
                  value: const Locale('ru'),
                  groupValue: LocaleService.instance.locale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      LocaleService.instance.setLocale(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  LocaleService.instance.setLocale(const Locale('ru'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(l10n.kyrgyz),
                leading: Radio<Locale>(
                  value: const Locale('ky'),
                  groupValue: LocaleService.instance.locale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      LocaleService.instance.setLocale(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  LocaleService.instance.setLocale(const Locale('ky'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.9),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _selectedIndex == 0 ? l10n.bankAnalysisTitle : l10n.reportsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: _showLanguageDialog,
            tooltip: l10n.language,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics),
              activeIcon: const Icon(Icons.analytics, size: 28),
              label: l10n.analysisTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.picture_as_pdf),
              activeIcon: const Icon(Icons.picture_as_pdf, size: 28),
              label: l10n.reportsTab,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  int? _selectedYear;
  int? _selectedMonth;
  List<XFile>? _selectedFiles;
  Set<int> _selectedBankIds = {};

  final List<int> _years =
      List.generate(DateTime.now().year - 2010 + 1, (index) => 2010 + index);

  Map<int, String> _getMonths(AppLocalizations l10n) => {
    1: l10n.january,
    2: l10n.february,
    3: l10n.march,
    4: l10n.april,
    5: l10n.may,
    6: l10n.june,
    7: l10n.july,
    8: l10n.august,
    9: l10n.september,
    10: l10n.october,
    11: l10n.november,
    12: l10n.december,
  };

  Future<void> _loadData() async {
    if (_selectedYear == null || _selectedMonth == null) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
      String formattedDate = '${_selectedYear}-$formattedMonth-01';

      final data = await _apiService.fetchBankReport(
        startDate: formattedDate,
        selectedBankIds:
            _selectedBankIds.isEmpty ? null : _selectedBankIds.toList(),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BankReportScreen(
              reportResponse: BankReportResponse.fromJson(data),
              comparativeAnalysis: data,
              startDate: formattedDate,
              selectedBankIds: _selectedBankIds.isEmpty ? null : _selectedBankIds.toList(),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final typeGroup = XTypeGroup(
        label: l10n.pdfFiles,
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
      );

      final files = await openFiles(
        acceptedTypeGroups: [typeGroup],
      );

      if (files.isNotEmpty) {
        setState(() {
          _selectedFiles = files;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.fileSelectionError} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      final newList = List<XFile>.from(_selectedFiles ?? []);
      newList.removeAt(index);
      _selectedFiles = newList.isEmpty ? null : newList;
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
      });

      final result = await _apiService.analyzePdfFiles(_selectedFiles!);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BankReportScreen(
              reportResponse: BankReportResponse.fromJson(result),
              comparativeAnalysis: result,
              // Для загруженных PDF файлов параметры не передаем
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
            content: Text('${l10n.fileSendError} $e'),
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

  Widget _buildBankSelectionSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectBanks,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              label: Text(l10n.allBanks),
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
    final l10n = AppLocalizations.of(context)!;
    final months = _getMonths(l10n);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          l10n.bankAnalysisTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.loading}\n${l10n.loadingTime}',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isError) ...[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.errorOccurred}\n$_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      l10n.selectPeriod,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: l10n.year,
                              border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: l10n.month,
                              border: const OutlineInputBorder(),
                            ),
                            value: _selectedMonth,
                            items: months.entries.map((entry) {
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
                    _buildBankSelectionSection(l10n),
                    const SizedBox(height: 20),
                    if (_selectedYear != null && _selectedMonth != null)
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.download),
                        label: Text(l10n.getAnalysis),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.uploadReports,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.upload_file),
                      label: Text(l10n.selectFiles),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_selectedFiles != null &&
                        _selectedFiles!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.selectedFiles} (${_selectedFiles!.length}):',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _selectedFiles!.length,
                          itemBuilder: (context, index) {
                            final file = _selectedFiles![index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.picture_as_pdf),
                              title: Text(file.name),
                              subtitle: FutureBuilder<int>(
                                future: file.length(),
                                builder: (context, snapshot) {
                                  return Text(snapshot.hasData
                                      ? '${(snapshot.data! / 1024).toStringAsFixed(2)} KB'
                                      : l10n.sizeCalculation);
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeFile(index),
                                tooltip: l10n.removeFile,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _uploadFiles,
                        icon: const Icon(Icons.send),
                        label: Text(l10n.sendFiles),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
