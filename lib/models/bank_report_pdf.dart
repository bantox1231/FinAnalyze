class BankReportPdf {
  final String bankName;
  final DateTime reportDate;
  final String reportUrl;
  final String reportTitle;
  final String reportType;

  BankReportPdf({
    required this.bankName,
    required this.reportDate,
    required this.reportUrl,
    required this.reportTitle,
    required this.reportType,
  });

  factory BankReportPdf.fromJson(Map<String, dynamic> json) {
    return BankReportPdf(
      bankName: json['bank_name'],
      reportDate: DateTime.parse(json['report_date']),
      reportUrl: json['report_url'],
      reportTitle: json['report_title'],
      reportType: json['report_type'],
    );
  }
} 