class BalanceResponse {
  final bool status;
  final String message;
  final BalanceData data;

  BalanceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: BalanceData.fromJson(json['data'] ?? {}),
    );
  }
}

class BalanceData {
  final String status;
  final String message;
  final String accountNumber;
  final String currency;
  final String customerNumber;
  final String customerName;
  final String balance;

  BalanceData({
    required this.status,
    required this.message,
    required this.accountNumber,
    required this.currency,
    required this.customerNumber,
    required this.customerName,
    required this.balance,
  });

  factory BalanceData.fromJson(Map<String, dynamic> json) {
    return BalanceData(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      accountNumber: json['accountnumber']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      customerNumber: json['customernumber']?.toString() ?? '',
      customerName: json['customername']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '',
    );
  }
}