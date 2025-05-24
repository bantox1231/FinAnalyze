import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComparativeAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic>? comparativeAnalysis;

  const ComparativeAnalysisWidget({
    Key? key,
    required this.comparativeAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('ComparativeAnalysisWidget data: $comparativeAnalysis');

    if (comparativeAnalysis == null ||
        !comparativeAnalysis!.containsKey('comparative_analysis') ||
        !comparativeAnalysis!['comparative_analysis']
            .containsKey('comparative_analysis')) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade100,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.comparativeAnalysisUnavailable,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.comparativeAnalysisDataNotFound,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final analysis =
        comparativeAnalysis!['comparative_analysis']['comparative_analysis'];
    final conclusions = analysis['conclusions'] ?? {};
    final assetsComparison = analysis['assets_comparison'] ?? {};
    final profitabilityComparison = analysis['profitability_comparison'] ?? {};
    final detailedConclusion = conclusions['detailed_conclusion'] ?? {};

    return Container(
      margin: const EdgeInsets.all(16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Красивый заголовок
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
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
                      Icons.compare_arrows,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.comparativeAnalysis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Рейтинг по активам
                  if (assetsComparison['ranking'] != null) ...[
                    _buildSectionHeader(l10n.assetsRanking,
                        Icons.account_balance_wallet, Colors.green),
                    const SizedBox(height: 16),
                    _buildRankingCard(
                      List<Map<String, dynamic>>.from(
                          assetsComparison['ranking']),
                      valueKey: 'value',
                      valueSuffix: ' ${l10n.thousandSom}',
                      color: Colors.green,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Рейтинг по прибыльности
                  if (profitabilityComparison['net_profit']?['ranking'] !=
                      null) ...[
                    _buildSectionHeader(l10n.netProfitRanking,
                        Icons.trending_up, Colors.blue),
                    const SizedBox(height: 16),
                    _buildRankingCard(
                      List<Map<String, dynamic>>.from(
                          profitabilityComparison['net_profit']['ranking']),
                      valueKey: 'value',
                      valueSuffix: ' ${l10n.thousandSom}',
                      color: Colors.blue,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ROA рейтинг
                  if (profitabilityComparison['roa']?['ranking'] != null) ...[
                    _buildSectionHeader(
                        l10n.roaRanking, Icons.show_chart, Colors.purple),
                    const SizedBox(height: 16),
                    _buildRankingCard(
                      List<Map<String, dynamic>>.from(
                          profitabilityComparison['roa']['ranking']),
                      valueKey: 'value',
                      valueSuffix: '%',
                      color: Colors.purple,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ROE рейтинг
                  if (profitabilityComparison['roe']?['ranking'] != null) ...[
                    _buildSectionHeader(
                        l10n.roeRanking, Icons.trending_up, Colors.teal),
                    const SizedBox(height: 16),
                    _buildRankingCard(
                      List<Map<String, dynamic>>.from(
                          profitabilityComparison['roe']['ranking']),
                      valueKey: 'value',
                      valueSuffix: '%',
                      color: Colors.teal,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Темпы роста
                  if (assetsComparison['growth_rates'] != null) ...[
                    _buildSectionHeader(l10n.assetsGrowthRates,
                        Icons.trending_up, Colors.orange),
                    const SizedBox(height: 16),
                    _buildRankingCard(
                      List<Map<String, dynamic>>.from(
                          assetsComparison['growth_rates']),
                      valueKey: 'growth_percent',
                      valueSuffix: '%',
                      color: Colors.orange,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Обзор рынка
                  if (detailedConclusion['market_overview'] != null) ...[
                    _buildInfoCard(
                      l10n.marketOverview,
                      detailedConclusion['market_overview'],
                      Colors.indigo,
                      Icons.assessment,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ключевые тренды
                  if (detailedConclusion['key_trends']?.isNotEmpty ??
                      false) ...[
                    _buildListCard(
                      l10n.keyTrends,
                      List<String>.from(detailedConclusion['key_trends']),
                      Colors.blue,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Рекомендации
                  if (detailedConclusion['recommendations']?.isNotEmpty ??
                      false) ...[
                    _buildListCard(
                      l10n.recommendations,
                      List<String>.from(detailedConclusion['recommendations']),
                      Colors.green,
                      Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Факторы риска
                  if (detailedConclusion['risk_factors']?.isNotEmpty ??
                      false) ...[
                    _buildListCard(
                      l10n.riskFactors,
                      List<String>.from(detailedConclusion['risk_factors']),
                      Colors.red,
                      Icons.warning_amber,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Прогноз
                  if (detailedConclusion['outlook'] != null) ...[
                    _buildInfoCard(
                      l10n.outlook,
                      detailedConclusion['outlook'],
                      Colors.purple,
                      Icons.insights,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(
    List<Map<String, dynamic>> ranking, {
    required String valueKey,
    String valueSuffix = '',
    required Color color,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: ranking.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          IconData positionIcon;
          Color positionColor;

          switch (index) {
            case 0:
              positionIcon = Icons.emoji_events;
              positionColor = Colors.amber;
              break;
            case 1:
              positionIcon = Icons.workspace_premium;
              positionColor = Colors.grey.shade600;
              break;
            case 2:
              positionIcon = Icons.military_tech;
              positionColor = Colors.brown;
              break;
            default:
              positionIcon = Icons.circle;
              positionColor = color;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  index < 3
                      ? positionColor.withOpacity(0.1)
                      : Colors.grey.shade50,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: index < 3
                    ? positionColor.withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: positionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: index < 3
                        ? Icon(
                            positionIcon,
                            color: positionColor,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: positionColor,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['bank'] ?? l10n.unknown,
                    style: TextStyle(
                      fontWeight: index < 3 ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item[valueKey]}$valueSuffix',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
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
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
      String title, List<String> items, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
