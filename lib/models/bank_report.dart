class BankReport {
  final String bankName;
  final String reportDate;
  final String reportUrl;
  final String reportTitle;
  final String reportType;

  BankReport({
    required this.bankName,
    required this.reportDate,
    required this.reportUrl,
    required this.reportTitle,
    required this.reportType,
  });

  factory BankReport.fromJson(Map<String, dynamic> json) {
    return BankReport(
      bankName: json['bank_name'] ?? '',
      reportDate: json['report_date'] ?? '',
      reportUrl: json['report_url'] ?? '',
      reportTitle: json['report_title'] ?? '',
      reportType: json['report_type'] ?? '',
    );
  }
}

class BankAnalysis {
  final String bankName;
  final String currentPeriod;
  final List<String> comparativePeriods;
  final Map<String, dynamic> balance;
  final Map<String, dynamic> incomeStatement;
  final Map<String, dynamic> ratios;
  final Map<String, dynamic> summary;
  final String? fullReport;

  BankAnalysis({
    required this.bankName,
    required this.currentPeriod,
    required this.comparativePeriods,
    required this.balance,
    required this.incomeStatement,
    required this.ratios,
    required this.summary,
    this.fullReport,
  });

  factory BankAnalysis.fromJson(Map<String, dynamic> json) {
    return BankAnalysis(
      bankName: json['bank_name'] ?? '',
      currentPeriod: json['current_period'] ?? '',
      comparativePeriods: List<String>.from(json['comparative_periods'] ?? []),
      balance: json['balance'] ?? {},
      incomeStatement: json['income_statement'] ?? {},
      ratios: json['ratios'] ?? {},
      summary: json['summary'] ?? {},
      fullReport: json['full_report'],
    );
  }
}

class BankReportResponse {
  final List<BankReport> reports;
  final Map<String, BankAnalysis> analyses;

  BankReportResponse({
    required this.reports,
    required this.analyses,
  });

  factory BankReportResponse.fromJson(Map<String, dynamic> json) {
    var reportsList = ((json['reports'] as List?) ?? [])
        .map((report) => BankReport.fromJson(report))
        .toList();

    var analysesMap = Map<String, BankAnalysis>.from(
      ((json['analyses'] as Map<String, dynamic>?) ?? {}).map(
        (key, value) => MapEntry(key, BankAnalysis.fromJson(value)),
      ),
    );

    return BankReportResponse(
      reports: reportsList,
      analyses: analysesMap,
    );
  }
} 