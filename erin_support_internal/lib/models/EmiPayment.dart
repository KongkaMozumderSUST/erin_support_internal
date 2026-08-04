import 'dart:convert';
class EmiPayment {
  final String accountNumber;
  final String scheduleNo;
  final DateTime scheduleDueDate;
  final double emiAmt;
  final double totSettled;
  final double totOverDue;

  EmiPayment({
    required this.accountNumber,
    required this.scheduleNo,
    required this.scheduleDueDate,
    required this.emiAmt,
    required this.totSettled,
    required this.totOverDue,
  });

  factory EmiPayment.fromJson(Map<String, dynamic> json) {
    return EmiPayment(
      accountNumber: json['account_number'],
      scheduleNo: json['schedule_no'],
      scheduleDueDate: DateTime.parse(json['schedule_due_date']),
      emiAmt: double.parse(json['emi_amt']),
      totOverDue: double.parse(json['tot_over_due']),
      totSettled: double.parse(json['tot_settled']),
    );
  }
}