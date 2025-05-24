import 'package:flutter/material.dart';
import '../models/bank_report.dart';
import '../widgets/bank_carousel.dart';
import '../widgets/comparative_analysis_widget.dart';

class BankReportScreen extends StatefulWidget {
  final BankReportResponse reportResponse;
  final Map<String, dynamic>? comparativeAnalysis;

  const BankReportScreen({
    Key? key, 
    required this.reportResponse,
    this.comparativeAnalysis,
  }) : super(key: key);

  @override
  State<BankReportScreen> createState() => _BankReportScreenState();
}

class _BankReportScreenState extends State<BankReportScreen> {
  late String selectedBank;

  @override
  void initState() {
    super.initState();
    if (widget.reportResponse.analyses.isEmpty) {
      throw Exception('Нет данных для анализа');
    }
    selectedBank = widget.reportResponse.analyses.keys.first;
  }

  void _onBankSelected(String bankKey) {
    setState(() {
      selectedBank = bankKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем comparative_analysis из общего ответа
    final comparativeAnalysisData = widget.comparativeAnalysis?['comparative_analysis'];
    
    print('Полные данные: ${widget.comparativeAnalysis}');
    print('Данные сравнительного анализа: $comparativeAnalysisData');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализ банков'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          BankCarousel(
            analyses: widget.reportResponse.analyses,
            selectedBank: selectedBank,
            onBankSelected: _onBankSelected,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBankAnalysis(widget.reportResponse.analyses[selectedBank]!),
                  ComparativeAnalysisWidget(
                    comparativeAnalysis: widget.comparativeAnalysis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAnalysis(BankAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analysis.bankName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Период: ${analysis.currentPeriod}'),
            const SizedBox(height: 16),

            // Баланс
            if (analysis.balance.isNotEmpty) ...[
              _buildSectionTitle('Баланс'),
              _buildBalanceSection(analysis.balance),
              const SizedBox(height: 16),
            ],

            // Отчет о прибылях и убытках
            if (analysis.incomeStatement.isNotEmpty) ...[
              _buildSectionTitle('Отчет о прибылях и убытках'),
              _buildIncomeStatementSection(analysis.incomeStatement),
              const SizedBox(height: 16),
            ],

            // Коэффициенты
            if (analysis.ratios.isNotEmpty) ...[
              _buildSectionTitle('Финансовые коэффициенты'),
              _buildRatiosSection(analysis.ratios),
              const SizedBox(height: 16),
            ],

            // Сильные стороны
            _buildSectionTitle('Сильные стороны'),
            ..._buildStrengths(analysis),
            const SizedBox(height: 16),

            // Точки внимания
            _buildSectionTitle('Точки внимания'),
            ..._buildAttentionPoints(analysis),
            const SizedBox(height: 16),

            // Заключение
            _buildSectionTitle('Заключение'),
            Text(analysis.summary['conclusion'] ?? 'Нет данных'),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection(Map<String, dynamic> balance) {
    final assets = balance['assets'];
    final liabilities = balance['liabilities'];
    final equity = balance['equity'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assets != null) ...[
          _buildSubsectionTitle('Активы'),
          _buildMetricRow(
            'Всего активов',
            '${assets['total']?['current'] ?? 0} тыс. сом',
          ),
          _buildMetricRow(
            'Изменение с начала года',
            '${assets['total']?['change_since_year_end_percent'] ?? 0}%',
          ),
          if (assets['components'] != null) ...[
            const SizedBox(height: 8),
            Text('Структура активов:', style: TextStyle(fontWeight: FontWeight.w500)),
            ...(assets['components'] as List).map((component) => 
              _buildMetricRow(
                component['name'] ?? '',
                '${component['current'] ?? 0} тыс. сом (${component['share_in_total'] ?? 0}%)',
              )
            ),
          ],
        ],

        if (liabilities != null) ...[
          const SizedBox(height: 12),
          _buildSubsectionTitle('Обязательства'),
          _buildMetricRow(
            'Всего обязательств',
            '${liabilities['total']?['current'] ?? 0} тыс. сом',
          ),
          _buildMetricRow(
            'Изменение с начала года',
            '${liabilities['total']?['change_since_year_end_percent'] ?? 0}%',
          ),
          if (liabilities['components'] != null) ...[
            const SizedBox(height: 8),
            Text('Структура обязательств:', style: TextStyle(fontWeight: FontWeight.w500)),
            ...(liabilities['components'] as List).map((component) => 
              _buildMetricRow(
                component['name'] ?? '',
                '${component['current'] ?? 0} тыс. сом (${component['share_in_total'] ?? 0}%)',
              )
            ),
          ],
        ],

        if (equity != null) ...[
          const SizedBox(height: 12),
          _buildSubsectionTitle('Капитал'),
          _buildMetricRow(
            'Всего капитал',
            '${equity['total']?['current'] ?? 0} тыс. сом',
          ),
          _buildMetricRow(
            'Изменение с начала года',
            '${equity['total']?['change_since_year_end_percent'] ?? 0}%',
          ),
          if (equity['components'] != null) ...[
            const SizedBox(height: 8),
            Text('Структура капитала:', style: TextStyle(fontWeight: FontWeight.w500)),
            ...(equity['components'] as List).map((component) => 
              _buildMetricRow(
                component['name'] ?? '',
                '${component['current'] ?? 0} тыс. сом (${component['share_in_total'] ?? 0}%)',
              )
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildIncomeStatementSection(Map<String, dynamic> incomeStatement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (incomeStatement['net_profit'] != null) ...[
          _buildMetricRow(
            'Чистая прибыль',
            '${incomeStatement['net_profit']['current']} тыс. сом',
          ),
          if (incomeStatement['net_profit']['change_percent'] != null)
            _buildMetricRow(
              'Изменение к прошлому году',
              '${incomeStatement['net_profit']['change_percent']}%',
            ),
        ],
        if (incomeStatement['net_interest_income'] != null)
          _buildMetricRow(
            'Чистый процентный доход',
            '${incomeStatement['net_interest_income']['current']} тыс. сом',
          ),
        if (incomeStatement['net_fee_income'] != null)
          _buildMetricRow(
            'Чистый комиссионный доход',
            '${incomeStatement['net_fee_income']['current']} тыс. сом',
          ),
      ],
    );
  }

  Widget _buildRatiosSection(Map<String, dynamic> ratios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Достаточность капитала
        if (ratios['capital_adequacy'] != null) ...[
          _buildSubsectionTitle('Достаточность капитала'),
          if (ratios['capital_adequacy']['car'] != null)
            _buildMetricRow(
              'CAR',
              '${ratios['capital_adequacy']['car']['current']}% (мин. ${ratios['capital_adequacy']['car']['regulatory_minimum']}%)',
            ),
          if (ratios['capital_adequacy']['tier1'] != null)
            _buildMetricRow(
              'Tier 1',
              '${ratios['capital_adequacy']['tier1']['current']}% (мин. ${ratios['capital_adequacy']['tier1']['regulatory_minimum']}%)',
            ),
        ],

        // Ликвидность
        if (ratios['liquidity'] != null) ...[
          const SizedBox(height: 12),
          _buildSubsectionTitle('Ликвидность'),
          if (ratios['liquidity']['lcr'] != null)
            _buildMetricRow(
              'LCR',
              '${ratios['liquidity']['lcr']['current']}% (мин. ${ratios['liquidity']['lcr']['regulatory_minimum']}%)',
            ),
          if (ratios['liquidity']['loan_to_deposit'] != null)
            _buildMetricRow(
              'Кредиты/Депозиты',
              '${ratios['liquidity']['loan_to_deposit']['current']}%',
            ),
        ],

        // Рентабельность
        if (ratios['profitability'] != null) ...[
          const SizedBox(height: 12),
          _buildSubsectionTitle('Рентабельность'),
          if (ratios['profitability']['roa'] != null)
            _buildMetricRow(
              'ROA',
              '${ratios['profitability']['roa']['current']}%',
            ),
          if (ratios['profitability']['roe'] != null)
            _buildMetricRow(
              'ROE',
              '${ratios['profitability']['roe']['current']}%',
            ),
        ],

        // Эффективность
        if (ratios['efficiency'] != null) ...[
          const SizedBox(height: 12),
          _buildSubsectionTitle('Эффективность'),
          if (ratios['efficiency']['cir'] != null)
            _buildMetricRow(
              'CIR',
              '${ratios['efficiency']['cir']['current']}%',
            ),
        ],
      ],
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildStrengths(BankAnalysis analysis) {
    List<String> strengths = List<String>.from(analysis.summary['strengths'] ?? []);
    return strengths.map((strength) => 
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(child: Text(strength)),
          ],
        ),
      )
    ).toList();
  }

  List<Widget> _buildAttentionPoints(BankAnalysis analysis) {
    List<String> points = List<String>.from(analysis.summary['attention_points'] ?? []);
    return points.map((point) => 
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16, color: Colors.orange)),
            Expanded(child: Text(point)),
          ],
        ),
      )
    ).toList();
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 