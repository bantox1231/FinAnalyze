import 'package:flutter/material.dart';
import '../models/bank_report.dart';

class BankCarousel extends StatelessWidget {
  final Map<String, BankAnalysis> analyses;
  final String selectedBank;
  final Function(String) onBankSelected;

  const BankCarousel({
    Key? key,
    required this.analyses,
    required this.selectedBank,
    required this.onBankSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: analyses.length,
        itemBuilder: (context, index) {
          String bankKey = analyses.keys.elementAt(index);
          BankAnalysis analysis = analyses[bankKey]!;
          bool isSelected = bankKey == selectedBank;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => onBankSelected(bankKey),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                foregroundColor: isSelected 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.primary,
                elevation: isSelected ? 4 : 1,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                analysis.bankName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 