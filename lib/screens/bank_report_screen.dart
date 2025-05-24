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

class _BankReportScreenState extends State<BankReportScreen>
    with TickerProviderStateMixin {
  late String selectedBank;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    selectedBank = widget.reportResponse.analyses.keys.first;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _onBankSelected(String bankKey) {
    setState(() {
      selectedBank = bankKey;
    });
    _cardAnimationController.reset();
    _cardAnimationController.forward();
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Theme.of(context).colorScheme.secondary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (color ?? Theme.of(context).colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAnalysis(BankAnalysis analysis) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Красивый заголовок банка
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.bankName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Период: ${analysis.currentPeriod}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Баланс
                    if (analysis.balance.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Баланс', Icons.account_balance_wallet,
                          color: Colors.green),
                      const SizedBox(height: 16),
                      _buildBalanceSection(analysis.balance),
                      const SizedBox(height: 24),
                    ],

                    // Отчет о прибылях и убытках
                    if (analysis.incomeStatement.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Отчет о прибылях и убытках', Icons.trending_up,
                          color: Colors.blue),
                      const SizedBox(height: 16),
                      _buildIncomeStatementSection(analysis.incomeStatement),
                      const SizedBox(height: 24),
                    ],

                    // Коэффициенты
                    if (analysis.ratios.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Финансовые коэффициенты', Icons.analytics,
                          color: Colors.purple),
                      const SizedBox(height: 16),
                      _buildRatiosSection(analysis.ratios),
                      const SizedBox(height: 24),
                    ],

                    // Сильные стороны
                    _buildSectionTitle('🌟 Сильные стороны'),
                    ..._buildStrengths(analysis),
                    const SizedBox(height: 16),

                    // Точки внимания
                    _buildSectionTitle('⚠️ Точки внимания'),
                    ..._buildAttentionPoints(analysis),
                    const SizedBox(height: 16),

                    // Заключение
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo.withOpacity(0.1),
                            Colors.indigo.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.summarize,
                                color: Colors.indigo.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Заключение',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.indigo.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              analysis.summary['conclusion'] ?? 'Нет данных',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(Map<String, dynamic> balance) {
    final assets = balance['assets'];
    final liabilities = balance['liabilities'];
    final equity = balance['equity'];

    return Column(
      children: [
        // Активы
        if (assets != null)
          _buildBalanceRow(
            '💰',
            'Всего активов',
            '${assets['total']?['current'] ?? 0} тыс. сом',
            'Изм: ${assets['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.green,
          ),

        // Обязательства
        if (liabilities != null)
          _buildBalanceRow(
            '💳',
            'Всего обязательств',
            '${liabilities['total']?['current'] ?? 0} тыс. сом',
            'Изм: ${liabilities['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.orange,
          ),

        // Капитал
        if (equity != null)
          _buildBalanceRow(
            '🏛️',
            'Всего капитал',
            '${equity['total']?['current'] ?? 0} тыс. сом',
            'Изм: ${equity['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildIncomeStatementSection(Map<String, dynamic> incomeStatement) {
    return Column(
      children: [
        if (incomeStatement['net_profit'] != null)
          _buildBalanceRow(
            '📈',
            'Чистая прибыль',
            '${incomeStatement['net_profit']['current']} тыс. сом',
            incomeStatement['net_profit']['change_percent'] != null
                ? 'Изм: ${incomeStatement['net_profit']['change_percent']}%'
                : null,
            Colors.green,
          ),
        if (incomeStatement['net_interest_income'] != null)
          _buildBalanceRow(
            '💹',
            'Чистый процентный доход',
            '${incomeStatement['net_interest_income']['current']} тыс. сом',
            null,
            Colors.blue,
          ),
        if (incomeStatement['net_fee_income'] != null)
          _buildBalanceRow(
            '💰',
            'Чистый комиссионный доход',
            '${incomeStatement['net_fee_income']['current']} тыс. сом',
            null,
            Colors.teal,
          ),
      ],
    );
  }

  Widget _buildRatiosSection(Map<String, dynamic> ratios) {
    return Column(
      children: [
        if (ratios['capital_adequacy']?['car'] != null)
          _buildBalanceRow(
            '🛡️',
            'CAR',
            '${ratios['capital_adequacy']['car']['current']}%',
            'мин. ${ratios['capital_adequacy']['car']['regulatory_minimum']}%',
            (ratios['capital_adequacy']['car']['current'] ?? 0) >=
                    (ratios['capital_adequacy']['car']['regulatory_minimum'] ??
                        0)
                ? Colors.green
                : Colors.red,
          ),
        if (ratios['liquidity']?['lcr'] != null)
          _buildBalanceRow(
            '💧',
            'LCR',
            '${ratios['liquidity']['lcr']['current']}%',
            'мин. ${ratios['liquidity']['lcr']['regulatory_minimum']}%',
            (ratios['liquidity']['lcr']['current'] ?? 0) >=
                    (ratios['liquidity']['lcr']['regulatory_minimum'] ?? 0)
                ? Colors.green
                : Colors.red,
          ),
        if (ratios['profitability']?['roa'] != null)
          _buildBalanceRow(
            '📊',
            'ROA',
            '${ratios['profitability']['roa']['current']}%',
            'Рентабельность активов',
            Colors.green,
          ),
        if (ratios['profitability']?['roe'] != null)
          _buildBalanceRow(
            '📈',
            'ROE',
            '${ratios['profitability']['roe']['current']}%',
            'Рентабельность капитала',
            Colors.green,
          ),
        if (ratios['efficiency']?['cir'] != null)
          _buildBalanceRow(
            '⚡',
            'CIR',
            '${ratios['efficiency']['cir']['current']}%',
            'Cost-to-Income Ratio',
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildBalanceRow(
      String icon, String title, String value, String? subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16), // Уменьшен padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12), // Немного уменьшен радиус
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34, // Уменьшен размер
            height: 34, // Уменьшен размер
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8), // Уменьшен радиус
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 16), // Уменьшен размер шрифта
              ),
            ),
          ),
          const SizedBox(width: 16), // Уменьшен отступ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15, // Немного уменьшен размер шрифта
                    color: Colors.grey.shade800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4), // Уменьшен отступ
                  _buildPercentageBadge(subtitle, color),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Уменьшены отступы
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16), // Уменьшен радиус
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16, // Немного уменьшен шрифт
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageBadge(String text, Color mainColor) {
    // Извлекаем процент из текста
    final percentMatch = RegExp(r'([-+]?\d+(?:\.\d+)?%)').firstMatch(text);
    if (percentMatch == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      );
    }

    final percentValue = percentMatch.group(1)!;
    final isPositive = !percentValue.startsWith('-');

    // СУПЕР ЯРКИЕ КОНТРАСТНЫЕ ЦВЕТА
    final bgColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final shadowColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Уменьшены отступы
      decoration: BoxDecoration(
        // ЯРКИЙ СПЛОШНОЙ ФОН
        color: bgColor,
        borderRadius: BorderRadius.circular(16), // Уменьшен радиус
        // МОЩНАЯ ТЕНЬ
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.6),
            blurRadius: 10, // Уменьшена тень
            offset: const Offset(0, 3), // Уменьшено смещение тени
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 16, // Уменьшена тень
            offset: const Offset(0, 6), // Уменьшено смещение тени
          ),
        ],
        // КОНТРАСТНАЯ РАМКА
        border: Border.all(
          color: shadowColor,
          width: 1.5, // Уменьшена ширина рамки
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16, // Немного уменьшен размер иконки
            color: Colors.white,
          ),
          const SizedBox(width: 5), // Уменьшено расстояние
          Text(
            percentValue,
            style: const TextStyle(
              fontSize: 14, // Размер текста оставлен прежним
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
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
    List<String> strengths =
        List<String>.from(analysis.summary['strengths'] ?? []);
    return strengths
        .map((strength) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(strength)),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildAttentionPoints(BankAnalysis analysis) {
    List<String> points =
        List<String>.from(analysis.summary['attention_points'] ?? []);
    return points
        .map((point) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point)),
                ],
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Крутой AppBar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
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
                        const Text(
                          'Анализ банков',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Карусель банков
            SlideTransition(
              position: _slideAnimation,
              child: BankCarousel(
                analyses: widget.reportResponse.analyses,
                selectedBank: selectedBank,
                onBankSelected: _onBankSelected,
              ),
            ),

            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBankAnalysis(
                        widget.reportResponse.analyses[selectedBank]!),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ComparativeAnalysisWidget(
                          comparativeAnalysis: widget.comparativeAnalysis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
