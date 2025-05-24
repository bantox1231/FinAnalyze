import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/bank_report.dart';
import '../widgets/bank_carousel.dart';
import '../widgets/comparative_analysis_widget.dart';
import '../services/locale_service.dart';
import '../services/api_service.dart';

// Расширение для добавления цветов
extension CustomColors on Colors {
  static const MaterialColor emerald = MaterialColor(
    0xFF10B981,
    <int, Color>{
      50: Color(0xFFECFDF5),
      100: Color(0xFFD1FAE5),
      200: Color(0xFFA7F3D0),
      300: Color(0xFF6EE7B7),
      400: Color(0xFF34D399),
      500: Color(0xFF10B981),
      600: Color(0xFF059669),
      700: Color(0xFF047857),
      800: Color(0xFF065F46),
      900: Color(0xFF064E3B),
    },
  );
}

class BankReportScreen extends StatefulWidget {
  final BankReportResponse reportResponse;
  final Map<String, dynamic>? comparativeAnalysis;
  final String? startDate;
  final List<int>? selectedBankIds;

  const BankReportScreen({
    Key? key,
    required this.reportResponse,
    this.comparativeAnalysis,
    this.startDate,
    this.selectedBankIds,
  }) : super(key: key);

  @override
  State<BankReportScreen> createState() => _BankReportScreenState();
}

class _BankReportScreenState extends State<BankReportScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late String selectedBank;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  BankReportResponse? _currentReportResponse;
  Map<String, dynamic>? _currentComparativeAnalysis;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    selectedBank = widget.reportResponse.analyses.keys.first;
    _currentReportResponse = widget.reportResponse;
    _currentComparativeAnalysis = widget.comparativeAnalysis;

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
                      _reloadReportForLanguage();
                    }
                  },
                ),
                onTap: () {
                  LocaleService.instance.setLocale(const Locale('ru'));
                  Navigator.of(context).pop();
                  _reloadReportForLanguage();
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
                      _reloadReportForLanguage();
                    }
                  },
                ),
                onTap: () {
                  LocaleService.instance.setLocale(const Locale('ky'));
                  Navigator.of(context).pop();
                  _reloadReportForLanguage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reloadReportForLanguage() async {
    // Перезагружаем отчет только если есть startDate
    if (widget.startDate == null) return;
    
    setState(() {
      _isReloading = true;
    });

    try {
      final result = await _apiService.fetchBankReport(
        startDate: widget.startDate!,
        selectedBankIds: widget.selectedBankIds,
      );

      if (mounted) {
        setState(() {
          _currentReportResponse = BankReportResponse.fromJson(result);
          _currentComparativeAnalysis = result;
          selectedBank = _currentReportResponse!.analyses.keys.first;
          _isReloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReloading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при перезагрузке: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 50,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.15),
                  (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.9),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAnalysis(BankAnalysis analysis, AppLocalizations l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildGradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Современный заголовок банка
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.bankName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${l10n.period} ${analysis.currentPeriod}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Баланс
                    if (analysis.balance.isNotEmpty) ...[
                      _buildSectionHeader(
                          l10n.balance, Icons.account_balance_wallet,
                          color: CustomColors.emerald.shade600),
                      const SizedBox(height: 8),
                      _buildBalanceSection(analysis.balance, l10n),
                      const SizedBox(height: 28),
                    ],

                    // Отчет о прибылях и убытках
                    if (analysis.incomeStatement.isNotEmpty) ...[
                      _buildSectionHeader(
                          l10n.incomeStatement, Icons.trending_up,
                          color: Colors.blue.shade600),
                      const SizedBox(height: 8),
                      _buildIncomeStatementSection(analysis.incomeStatement, l10n),
                      const SizedBox(height: 28),
                    ],

                    // Коэффициенты
                    if (analysis.ratios.isNotEmpty) ...[
                      _buildSectionHeader(
                          l10n.financialRatios, Icons.analytics,
                          color: Colors.purple.shade600),
                      const SizedBox(height: 8),
                      _buildRatiosSection(analysis.ratios, l10n),
                      const SizedBox(height: 28),
                    ],

                    // Сильные стороны и точки внимания
                    _buildAnalysisInsights(analysis, l10n),

                    const SizedBox(height: 24),

                    // Заключение
                    _buildConclusionSection(analysis, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(Map<String, dynamic> balance, AppLocalizations l10n) {
    final assets = balance['assets'];
    final liabilities = balance['liabilities'];
    final equity = balance['equity'];

    return Column(
      children: [
        // Активы
        if (assets != null)
          _buildBalanceRow(
            '💰',
            l10n.totalAssets,
            '${assets['total']?['current'] ?? 0} ${l10n.thousandSom}',
            '${l10n.change} ${assets['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.green,
          ),

        // Обязательства
        if (liabilities != null)
          _buildBalanceRow(
            '💳',
            l10n.totalLiabilities,
            '${liabilities['total']?['current'] ?? 0} ${l10n.thousandSom}',
            '${l10n.change} ${liabilities['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.orange,
          ),

        // Капитал
        if (equity != null)
          _buildBalanceRow(
            '🏛️',
            l10n.totalEquity,
            '${equity['total']?['current'] ?? 0} ${l10n.thousandSom}',
            '${l10n.change} ${equity['total']?['change_since_year_end_percent'] ?? 0}%',
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildIncomeStatementSection(Map<String, dynamic> incomeStatement, AppLocalizations l10n) {
    return Column(
      children: [
        if (incomeStatement['net_profit'] != null)
          _buildBalanceRow(
            '📈',
            l10n.netProfit,
            '${incomeStatement['net_profit']['current']} ${l10n.thousandSom}',
            incomeStatement['net_profit']['change_percent'] != null
                ? '${l10n.change} ${incomeStatement['net_profit']['change_percent']}%'
                : null,
            Colors.green,
          ),
        if (incomeStatement['net_interest_income'] != null)
          _buildBalanceRow(
            '💹',
            l10n.netInterestIncome,
            '${incomeStatement['net_interest_income']['current']} ${l10n.thousandSom}',
            null,
            Colors.blue,
          ),
        if (incomeStatement['net_fee_income'] != null)
          _buildBalanceRow(
            '💰',
            l10n.netFeeIncome,
            '${incomeStatement['net_fee_income']['current']} ${l10n.thousandSom}',
            null,
            Colors.teal,
          ),
      ],
    );
  }

  Widget _buildRatiosSection(Map<String, dynamic> ratios, AppLocalizations l10n) {
    return Column(
      children: [
        if (ratios['capital_adequacy']?['car'] != null)
          _buildBalanceRow(
            '🛡️',
            l10n.car,
            '${ratios['capital_adequacy']['car']['current']}%',
            '${l10n.min} ${ratios['capital_adequacy']['car']['regulatory_minimum']}%',
            (ratios['capital_adequacy']['car']['current'] ?? 0) >=
                    (ratios['capital_adequacy']['car']['regulatory_minimum'] ??
                        0)
                ? Colors.green
                : Colors.red,
          ),
        if (ratios['liquidity']?['lcr'] != null)
          _buildBalanceRow(
            '💧',
            l10n.lcr,
            '${ratios['liquidity']['lcr']['current']}%',
            '${l10n.min} ${ratios['liquidity']['lcr']['regulatory_minimum']}%',
            (ratios['liquidity']['lcr']['current'] ?? 0) >=
                    (ratios['liquidity']['lcr']['regulatory_minimum'] ?? 0)
                ? Colors.green
                : Colors.red,
          ),
        if (ratios['profitability']?['roa'] != null)
          _buildBalanceRow(
            '📊',
            l10n.roa,
            '${ratios['profitability']['roa']['current']}%',
            l10n.returnOnAssets,
            Colors.green,
          ),
        if (ratios['profitability']?['roe'] != null)
          _buildBalanceRow(
            '📈',
            l10n.roe,
            '${ratios['profitability']['roe']['current']}%',
            l10n.returnOnEquity,
            Colors.green,
          ),
        if (ratios['efficiency']?['cir'] != null)
          _buildBalanceRow(
            '⚡',
            l10n.cir,
            '${ratios['efficiency']['cir']['current']}%',
            l10n.costToIncomeRatio,
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildBalanceRow(
      String icon, String title, String value, String? subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(0.06),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  _buildPercentageBadge(subtitle, color),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.12),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.9),
                fontSize: 16,
                letterSpacing: 0.3,
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    final percentValue = percentMatch.group(1)!;
    final isPositive = !percentValue.startsWith('-');

    final bgColor = isPositive ? CustomColors.emerald.shade500 : Colors.red.shade500;
    final shadowColor = isPositive ? CustomColors.emerald.shade600 : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            percentValue,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInsights(BankAnalysis analysis, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Сильные стороны
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomColors.emerald.shade50,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CustomColors.emerald.shade100,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CustomColors.emerald.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: CustomColors.emerald.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.strengths,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CustomColors.emerald.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildStrengthsList(analysis),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Точки внимания
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.shade100,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.attentionPoints,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildAttentionPointsList(analysis),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStrengthsList(BankAnalysis analysis) {
    List<String> strengths = List<String>.from(analysis.summary['strengths'] ?? []);
    return strengths.take(3).map((strength) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: CustomColors.emerald.shade500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildAttentionPointsList(BankAnalysis analysis) {
    List<String> points = List<String>.from(analysis.summary['attention_points'] ?? []);
    return points.take(3).map((point) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildConclusionSection(BankAnalysis analysis, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.indigo.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade100,
                      Colors.indigo.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.indigo.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.conclusion,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.indigo.shade100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              analysis.summary['conclusion'] ?? l10n.noData,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleService.instance,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade50,
                  Colors.white,
                  Colors.grey.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                // Современный AppBar
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                l10n.bankAnalysis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.language, color: Colors.white, size: 20),
                          onPressed: () => _showLanguageDialog(),
                          tooltip: l10n.language,
                        ),
                      ),
                    ],
                  ),
                ),

                // Карусель банков
                SlideTransition(
                  position: _slideAnimation,
                  child: BankCarousel(
                    analyses: _currentReportResponse?.analyses ?? widget.reportResponse.analyses,
                    selectedBank: selectedBank,
                    onBankSelected: _onBankSelected,
                  ),
                ),

                // Основной контент
                Expanded(
                  child: _isReloading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.loading,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildBankAnalysis(
                                  (_currentReportResponse ?? widget.reportResponse).analyses[selectedBank]!, l10n),
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ComparativeAnalysisWidget(
                                    comparativeAnalysis: _currentComparativeAnalysis ?? widget.comparativeAnalysis,
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
      },
    );
  }
}
