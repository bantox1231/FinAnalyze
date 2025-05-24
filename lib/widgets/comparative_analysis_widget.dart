import 'package:flutter/material.dart';

class ComparativeAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic>? comparativeAnalysis;

  const ComparativeAnalysisWidget({
    Key? key,
    required this.comparativeAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ComparativeAnalysisWidget data: $comparativeAnalysis');
    
    if (comparativeAnalysis == null || 
        !comparativeAnalysis!.containsKey('comparative_analysis') ||
        !comparativeAnalysis!['comparative_analysis'].containsKey('comparative_analysis')) {
      return const Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Сравнительный анализ недоступен',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final analysis = comparativeAnalysis!['comparative_analysis']['comparative_analysis'];
    final conclusions = analysis['conclusions'] ?? {};
    final assetsComparison = analysis['assets_comparison'] ?? {};
    final profitabilityComparison = analysis['profitability_comparison'] ?? {};
    final detailedConclusion = conclusions['detailed_conclusion'] ?? {};

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сравнительный анализ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Рейтинг по активам
            if (assetsComparison['ranking'] != null) ...[
              _buildSectionTitle('Рейтинг по активам'),
              ..._buildRanking(
                List<Map<String, dynamic>>.from(assetsComparison['ranking']),
                valueKey: 'value',
                valueSuffix: ' тыс. сом',
              ),
              const SizedBox(height: 16),
            ],
            
            // Рейтинг по прибыльности
            if (profitabilityComparison['net_profit']?['ranking'] != null) ...[
              _buildSectionTitle('Рейтинг по чистой прибыли'),
              ..._buildRanking(
                List<Map<String, dynamic>>.from(profitabilityComparison['net_profit']['ranking']),
                valueKey: 'value',
                valueSuffix: ' тыс. сом',
              ),
              const SizedBox(height: 16),
            ],

            // ROA рейтинг
            if (profitabilityComparison['roa']?['ranking'] != null) ...[
              _buildSectionTitle('Рейтинг по ROA'),
              ..._buildRanking(
                List<Map<String, dynamic>>.from(profitabilityComparison['roa']['ranking']),
                valueKey: 'value',
                valueSuffix: '%',
              ),
              const SizedBox(height: 16),
            ],

            // ROE рейтинг
            if (profitabilityComparison['roe']?['ranking'] != null) ...[
              _buildSectionTitle('Рейтинг по ROE'),
              ..._buildRanking(
                List<Map<String, dynamic>>.from(profitabilityComparison['roe']['ranking']),
                valueKey: 'value',
                valueSuffix: '%',
              ),
              const SizedBox(height: 16),
            ],

            // Темпы роста
            if (assetsComparison['growth_rates'] != null) ...[
              _buildSectionTitle('Темпы роста активов'),
              ..._buildRanking(
                List<Map<String, dynamic>>.from(assetsComparison['growth_rates']),
                valueKey: 'growth_percent',
                valueSuffix: '%',
              ),
              const SizedBox(height: 16),
            ],
            
            // Обзор рынка
            if (detailedConclusion['market_overview'] != null) ...[
              _buildSectionTitle('Обзор рынка'),
              Text(detailedConclusion['market_overview']),
              const SizedBox(height: 16),
            ],

            // Ключевые тренды
            if (detailedConclusion['key_trends']?.isNotEmpty ?? false) ...[
              _buildSectionTitle('Ключевые тренды'),
              ...List<String>.from(detailedConclusion['key_trends'])
                  .map((trend) => _buildBulletPoint(trend))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // Рекомендации
            if (detailedConclusion['recommendations']?.isNotEmpty ?? false) ...[
              _buildSectionTitle('Рекомендации'),
              ...List<String>.from(detailedConclusion['recommendations'])
                  .map((recommendation) => _buildBulletPoint(recommendation))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // Факторы риска
            if (detailedConclusion['risk_factors']?.isNotEmpty ?? false) ...[
              _buildSectionTitle('Факторы риска'),
              ...List<String>.from(detailedConclusion['risk_factors'])
                  .map((risk) => _buildBulletPoint(risk))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // Прогноз
            if (detailedConclusion['outlook'] != null) ...[
              _buildSectionTitle('Прогноз'),
              Text(detailedConclusion['outlook']),
            ],
          ],
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  List<Widget> _buildRanking(List<Map<String, dynamic>> ranking, {
    required String valueKey,
    String valueSuffix = '',
  }) {
    return ranking.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(item['bank'] ?? 'Неизвестно'),
            ),
            Text(
              '${item[valueKey]}$valueSuffix',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }).toList();
  }
} 