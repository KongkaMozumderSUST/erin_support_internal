class SaleRecord {
  final String imei1;
  final String imei2;
  final int customerId;
  final String customerName;
  final double price;
  final double downPayment;
  final String downPaymentDate;
  final double totalPaid;
  final double due;
  final int noOfInstallment;
  final String nextInstallmentDate;
  final String model;
  final String brand;
  final String color;
  final String retailName;
  final String posInvoiceNumber;
  final String salesPersonName;
  final int emiStatus;
  final String systemAppStatus;
  final String lastSync;
  final String lastLocation;
  final String password;
  final String deviceStatus;
  final String lockResponse;
  final int forceLockStatus;

  SaleRecord({
    required this.imei1,
    required this.imei2,
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
    required this.lastSync,
    required this.lastLocation,
    required this.password,
    required this.deviceStatus,
    required this.lockResponse,
    required this.forceLockStatus,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      imei1: json['imei_1'] ?? '',
      imei2: json['imei_2'] ?? '',
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      downPayment: (json['down_payment'] ?? 0).toDouble(),
      downPaymentDate: json['down_payment_date'] ?? '',
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
      noOfInstallment: json['no_of_installment'] ?? 0,
      nextInstallmentDate: json['next_installment_date'] ?? '',
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
      color: json['color'] ?? '',
      retailName: json['retail_name'] ?? '',
      posInvoiceNumber: json['pos_invoice_number'] ?? '',
      salesPersonName: json['sales_person_name'] ?? '',
      emiStatus: json['emi_status'] ?? 0,
      systemAppStatus: json['system_app_status'] ?? '',
      lastSync: json['last_sync'] ?? '',
      lastLocation: json['last_location'] ?? '',
      password: json['password'] ?? '',
      deviceStatus: json['device_status'] ?? '',
      lockResponse: json['lock_response'] ?? '',
      forceLockStatus: json['force_lock_status'] ?? 0,
    );
  }
}