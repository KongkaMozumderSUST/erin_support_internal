class PayProtectData {
  final String imei_1;
  final String imei_2;
  final String customerId;
  final String customerName;
  final String price;
  final String downPayment;
  final DateTime downPaymentDate;
  final String totalPaid;
  final String due;
  final String noOfInstallment;
  final DateTime nextInstallmentDate;
  final String model;
  final String brand;
  final String color;
  final String retailName;
  final String posInvoiceNumber;
  final String salesPersonName;
  final String emiStatus;
  final String systemAppStatus;
  final  String lastSync;
  final String password;
  final String deviceStatus;
  final String lockResponse;
  final String forceLockStatus;

  PayProtectData(
  {
    required this.imei_1,
    required this.imei_2,
    required this.customerId,
    required this.customerName,
    required this.price,
    required this.downPayment,
    required this.downPaymentDate,
    required this.totalPaid,
    required this.due,
    required this.noOfInstallment,
    required this.nextInstallmentDate,
    required this.model,
    required this.brand,
    required this.color,
    required this.retailName,
    required this.posInvoiceNumber,
    required this.salesPersonName,
    required this.emiStatus,
    required this.systemAppStatus,
    required this.password,
    required this.deviceStatus,
    required this.
  })

}

// {
// "message": "Sale record retrieved successfully",
// "status": 200,
// "data": [
// {
// "imei_1": "351449780859843",
// "imei_2": "351449780859850",
// "customer_id": 300935,
// "customer_name": "MD. RABBI",
// "price": 15844,
// "down_payment": 4753.2,
// "down_payment_date": "2026-03-23",
// "total_paid": 14246.2,
// "due": 5593.7,
// "no_of_installment": 6,
// "next_installment_date": "2026-09-19",
// "model": "Nexg N75",
// "brand": "Walton",
// "color": "Dark Purple",
// "retail_name": "al amin telecom",
// "pos_invoice_number": "300935",
// "sales_person_name": "",
// "emi_status": 1,
// "system_app_status": "Active",
// "last_sync": "2026-08-30 20:15:02",
// "last_location": "7X7W+V5F, Bangladesh",
// "password": "846522",
// "device_status": "Unlock",
// "lock_response": "Unlock",
// "force_lock_status": 0
// }
// ]
// }