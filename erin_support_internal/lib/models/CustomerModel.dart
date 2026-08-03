import 'dart:convert';

class ApiResponse {
  final bool? success;
  final String? message;
  final String? token;
  final LoginData? data;

  ApiResponse({this.success, this.message, this.token, this.data});

  factory ApiResponse.fromMap(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      data: json['data'] != null ? LoginData.fromMap(json['data']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'data': data?.toMap(),
    };
  }
}

class LoginData {
  final int? id;
  final String? uuid;
  final String? customerUuid;
  final String? applicationId;
  final String? userRefNo;
  final String? bankId;
  final String? productId;
  final String? emiId;
  final ProductSelectionInfo? productSelectionInfo;
  final ProductInfo? productInfo;
  final DownPaymentInfo? downPaymentInfo;
  final EmiPayableInfo? emiPayableInfo;
  final CreditScoreInfo? creditScoreInfo;
  final LoanCreationDetails? loanCreationDetails;
  final String? workflow;
  final String? profee;
  final String? cib;
  final String? tcsa;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final DmsInfo? dmsInfo;
  final MdmInfo? mdmInfo;
  final List<EmiInfo>? emiInfo;
  final CustomerInfo? customerInfo;
  final LoanSimDetails? loanSimDetails;
  final Product? product;

  LoginData({
    this.id,
    this.uuid,
    this.customerUuid,
    this.applicationId,
    this.userRefNo,
    this.bankId,
    this.productId,
    this.emiId,
    this.productSelectionInfo,
    this.productInfo,
    this.downPaymentInfo,
    this.emiPayableInfo,
    this.creditScoreInfo,
    this.loanCreationDetails,
    this.workflow,
    this.profee,
    this.cib,
    this.tcsa,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.dmsInfo,
    this.mdmInfo,
    this.emiInfo,
    this.customerInfo,
    this.loanSimDetails,
    this.product,
  });

  factory LoginData.fromMap(Map<String, dynamic> json) {
    T? parseNested<T>(dynamic value, T Function(Map<String, dynamic>) fromMap) {
      if (value == null) return null;
      try {
        final map = value is String ? jsonDecode(value) : value;
        if (map is Map<String, dynamic>) {
          return fromMap(map);
        }
      } catch (_) {}
      return null;
    }

    List<T>? parseList<T>(
        dynamic value, T Function(Map<String, dynamic>) fromMap) {
      if (value == null) return null;
      try {
        final decoded = value is String ? jsonDecode(value) : value;
        if (decoded is List) {
          return decoded.map((e) => fromMap(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
      return null;
    }

    return LoginData(
      id: json['id'],
      uuid: json['uuid'],
      customerUuid: json['customer_uuid'],
      applicationId: json['application_id'],
      userRefNo: json['user_ref_no'],
      bankId: json['bank_id']?.toString(),
      productId: json['product_id']?.toString(),
      emiId: json['emi_id']?.toString(),
      productSelectionInfo: parseNested(
          json['product_selection_info'], ProductSelectionInfo.fromMap),
      productInfo: parseNested(json['product_info'], ProductInfo.fromMap),
      downPaymentInfo:
      parseNested(json['down_payment_info'], DownPaymentInfo.fromMap),
      emiPayableInfo:
      parseNested(json['emi_payable_info'], EmiPayableInfo.fromMap),
      creditScoreInfo:
      parseNested(json['credit_score_info'], CreditScoreInfo.fromMap),
      loanCreationDetails: parseNested(
          json['loan_creation_details'], LoanCreationDetails.fromMap),
      workflow: json['workflow'],
      profee: json['profee']?.toString(),
      cib: json['cib']?.toString(),
      tcsa: json['tcsa']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dmsInfo: parseNested(json['dms_info'], DmsInfo.fromMap),
      mdmInfo: parseNested(json['mdm_info'], MdmInfo.fromMap),
      emiInfo: parseList(json['emi_info'], EmiInfo.fromMap),
      customerInfo: parseNested(json['customer_info'], CustomerInfo.fromMap),
      loanSimDetails:
      parseNested(json['loan_sim_details'], LoanSimDetails.fromMap),
      product: parseNested(json['product'], Product.fromMap),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'customer_uuid': customerUuid,
      'application_id': applicationId,
      'user_ref_no': userRefNo,
      'bank_id': bankId,
      'product_id': productId,
      'emi_id': emiId,
      'workflow': workflow,
      'profee': profee,
      'cib': cib,
      'tcsa': tcsa,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer_info': customerInfo?.toMap(),
      'dms_info': dmsInfo?.toMap(),
      'mdm_info': mdmInfo?.toMap(),
      'product': product?.toMap(),
      'product_selection_info': productSelectionInfo?.toMap(),
      'product_info': productInfo?.toMap(),
      'down_payment_info': downPaymentInfo?.toMap(),
      'emi_payable_info': emiPayableInfo?.toMap(),
      'credit_score_info': creditScoreInfo?.toMap(),
      'loan_creation_details': loanCreationDetails?.toMap(),
      'loan_sim_details': loanSimDetails?.toMap(),
      'emi_info': emiInfo?.map((e) => e.toMap()).toList(),
    };
  }
}

class ProductSelectionInfo {
  final int? productId;
  final String? productName;
  final VariantSpecification? specification;
  final ColorInfo? color;
  final BrandInfo? brand;

  ProductSelectionInfo({
    this.productId,
    this.productName,
    this.specification,
    this.color,
    this.brand,
  });

  factory ProductSelectionInfo.fromMap(Map<String, dynamic> json) {
    return ProductSelectionInfo(
      productId: json['product_id'],
      productName: json['product_name'],
      specification: json['specification'] != null
          ? VariantSpecification.fromMap(json['specification'])
          : null,
      color: json['color'] != null ? ColorInfo.fromMap(json['color']) : null,
      brand: json['brand'] != null ? BrandInfo.fromMap(json['brand']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'specification': specification?.toMap(),
      'color': color?.toMap(),
      'brand': brand?.toMap(),
    };
  }
}

class VariantSpecification {
  final String? variantName;
  final String? basePrice;
  final String? promotionPrice;

  VariantSpecification(
      {this.variantName, this.basePrice, this.promotionPrice});

  factory VariantSpecification.fromMap(Map<String, dynamic> json) {
    return VariantSpecification(
      variantName: json['variant_name'],
      basePrice: json['basePrice']?.toString(),
      promotionPrice: json['promotionPrice']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variant_name': variantName,
      'basePrice': basePrice,
      'promotionPrice': promotionPrice,
    };
  }
}

class ColorInfo {
  final int? id;
  final String? colorName;
  final String? uuid;
  final String? colorCode;

  ColorInfo({this.id, this.colorName, this.uuid, this.colorCode});

  factory ColorInfo.fromMap(Map<String, dynamic> json) {
    return ColorInfo(
      id: json['id'],
      colorName: json['color_name'],
      uuid: json['uuid'],
      colorCode: json['color_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color_name': colorName,
      'uuid': uuid,
      'color_code': colorCode,
    };
  }
}

class BrandInfo {
  final String? uuid;
  final String? name;
  final String? iconBase64;

  BrandInfo({this.uuid, this.name, this.iconBase64});

  factory BrandInfo.fromMap(Map<String, dynamic> json) {
    return BrandInfo(
      uuid: json['uuid'],
      name: json['name'],
      iconBase64: json['iconBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'iconBase64': iconBase64,
    };
  }
}

class DownPaymentInfo {
  final String? processingFee;
  final String? downPayment;
  final String? cibCharge;
  final String? totalDownPayment;

  DownPaymentInfo(
      {this.processingFee,
        this.downPayment,
        this.cibCharge,
        this.totalDownPayment});

  factory DownPaymentInfo.fromMap(Map<String, dynamic> json) {
    return DownPaymentInfo(
      processingFee: json['processing_fee']?.toString(),
      downPayment: json['down_payment']?.toString(),
      cibCharge: json['cib_charge']?.toString(),
      totalDownPayment: json['total_down_payment']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'processing_fee': processingFee,
      'down_payment': downPayment,
      'cib_charge': cibCharge,
      'total_down_payment': totalDownPayment,
    };
  }
}

class EmiPayableInfo {
  final int? emiId;
  final String? emiDuration;
  final String? initialAmount;
  final String? totalAmount;
  final String? interestRate;
  final String? interestAmount;
  final String? monthlyAmount;

  EmiPayableInfo({
    this.emiId,
    this.emiDuration,
    this.initialAmount,
    this.totalAmount,
    this.interestRate,
    this.interestAmount,
    this.monthlyAmount,
  });

  factory EmiPayableInfo.fromMap(Map<String, dynamic> json) {
    return EmiPayableInfo(
      emiId: json['emi_id'],
      emiDuration: json['emi_duration']?.toString(),
      initialAmount: json['initial_amount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      interestRate: json['interest_rate']?.toString(),
      interestAmount: json['interest_amount']?.toString(),
      monthlyAmount: json['monthly_amount']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emi_id': emiId,
      'emi_duration': emiDuration,
      'initial_amount': initialAmount,
      'total_amount': totalAmount,
      'interest_rate': interestRate,
      'interest_amount': interestAmount,
      'monthly_amount': monthlyAmount,
    };
  }
}

class CreditScoreInfo {
  final int? finalScore;
  final int? recommendedLoan;
  final AchievedScore? achievedScore;

  CreditScoreInfo({this.finalScore, this.recommendedLoan, this.achievedScore});

  factory CreditScoreInfo.fromMap(Map<String, dynamic> json) {
    return CreditScoreInfo(
      finalScore: json['final_score'],
      recommendedLoan: json['recommanded_loan'],
      achievedScore: json['achieved_score'] != null
          ? AchievedScore.fromMap(json['achieved_score'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'final_score': finalScore,
      'recommanded_loan': recommendedLoan,
      'achieved_score': achievedScore?.toMap(),
    };
  }
}

class AchievedScore {
  final double? psychometric;
  final double? creditHistoryScore;
  final double? riskAssessmentScore;

  AchievedScore(
      {this.psychometric,
        this.creditHistoryScore,
        this.riskAssessmentScore});

  factory AchievedScore.fromMap(Map<String, dynamic> json) {
    return AchievedScore(
      psychometric: (json['psychometric'] as num?)?.toDouble(),
      creditHistoryScore: (json['credit_history_score'] as num?)?.toDouble(),
      riskAssessmentScore: (json['risk_assessment_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psychometric': psychometric,
      'credit_history_score': creditHistoryScore,
      'risk_assessment_score': riskAssessmentScore,
    };
  }
}

class LoanCreationDetails {
  final String? statuscode;
  final String? statusdescription;
  final String? loanaccno;
  final String? brn;
  final String? valdt;
  final String? matdt;
  final String? ccy;
  final String? amtfinanced;
  final String? emicollectionAc;
  final String? interestRate;
  final List<EmiSchedule>? emischedule;

  LoanCreationDetails({
    this.statuscode,
    this.statusdescription,
    this.loanaccno,
    this.brn,
    this.valdt,
    this.matdt,
    this.ccy,
    this.amtfinanced,
    this.emicollectionAc,
    this.interestRate,
    this.emischedule,
  });

  factory LoanCreationDetails.fromMap(Map<String, dynamic> json) {
    return LoanCreationDetails(
      statuscode: json['statuscode']?.toString(),
      statusdescription: json['statusdescription']?.toString(),
      loanaccno: json['loanaccno']?.toString(),
      brn: json['brn']?.toString(),
      valdt: json['valdt']?.toString(),
      matdt: json['matdt']?.toString(),
      ccy: json['ccy']?.toString(),
      amtfinanced: json['amtfinanced']?.toString(),
      emicollectionAc: json['emicollectioN_AC']?.toString(),
      interestRate: json['interesT_RATE']?.toString(),
      emischedule: json['emischedule'] != null
          ? (json['emischedule'] as List)
          .map((e) => EmiSchedule.fromMap(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statuscode': statuscode,
      'statusdescription': statusdescription,
      'loanaccno': loanaccno,
      'brn': brn,
      'valdt': valdt,
      'matdt': matdt,
      'ccy': ccy,
      'amtfinanced': amtfinanced,
      'emicollectioN_AC': emicollectionAc,
      'interesT_RATE': interestRate,
      'emischedule': emischedule?.map((e) => e.toMap()).toList(),
    };
  }
}

class EmiSchedule {
  final String? scheduleNumber;
  final String? scheduleDate;
  final String? emiAmount;

  EmiSchedule({this.scheduleNumber, this.scheduleDate, this.emiAmount});

  factory EmiSchedule.fromMap(Map<String, dynamic> json) {
    return EmiSchedule(
      scheduleNumber: json['scheduleNumber']?.toString(),
      scheduleDate: json['scheduleDate']?.toString(),
      emiAmount: json['emiAmount']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduleNumber': scheduleNumber,
      'scheduleDate': scheduleDate,
      'emiAmount': emiAmount,
    };
  }
}

class DmsInfo {
  final String? dmsId;
  final String? tcsaName;
  final String? partner;
  final String? category;
  final String? storeName;

  DmsInfo(
      {this.dmsId,
        this.tcsaName,
        this.partner,
        this.category,
        this.storeName});

  factory DmsInfo.fromMap(Map<String, dynamic> json) {
    return DmsInfo(
      dmsId: json['dms_id']?.toString(),
      tcsaName: json['tcsa_name']?.toString(),
      partner: json['partner']?.toString(),
      category: json['category']?.toString(),
      storeName: json['store_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dms_id': dmsId,
      'tcsa_name': tcsaName,
      'partner': partner,
      'category': category,
      'store_name': storeName,
    };
  }
}

class MdmInfo {
  final String? customerId;
  final String? imei1;
  final String? imei2;
  final String? downPayment;

  MdmInfo({this.customerId, this.imei1, this.imei2, this.downPayment});

  factory MdmInfo.fromMap(Map<String, dynamic> json) {
    return MdmInfo(
      customerId: json['customer_id']?.toString(),
      imei1: json['imei_1']?.toString(),
      imei2: json['imei_2']?.toString(),
      downPayment: json['down_payment']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'imei_1': imei1,
      'imei_2': imei2,
      'down_payment': downPayment,
    };
  }
}

class EmiInfo {
  final String? scheduleNumber;
  final String? scheduleDate;
  final String? emiAmount;
  final String? status;

  EmiInfo({this.scheduleNumber, this.scheduleDate, this.emiAmount, this.status});

  factory EmiInfo.fromMap(Map<String, dynamic> json) {
    return EmiInfo(
      scheduleNumber: json['scheduleNumber']?.toString(),
      scheduleDate: json['scheduleDate']?.toString(),
      emiAmount: json['emiAmount']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduleNumber': scheduleNumber,
      'scheduleDate': scheduleDate,
      'emiAmount': emiAmount,
      'status': status,
    };
  }
}

class CustomerInfo {
  final String? name;
  final String? email;
  final String? fatherName;
  final String? motherName;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? highestEducation;
  final String? religion;
  final String? children;
  final String? oldestChild;
  final String? spouseName;
  final String? haveSpouseOccupation;
  final String? haveChildren;
  final String? spouseOccupation;
  final String? maritalStatus;
  final String? image;

  CustomerInfo({
    this.name,
    this.email,
    this.fatherName,
    this.motherName,
    this.phone,
    this.gender,
    this.dob,
    this.highestEducation,
    this.religion,
    this.children,
    this.oldestChild,
    this.spouseName,
    this.haveSpouseOccupation,
    this.haveChildren,
    this.spouseOccupation,
    this.maritalStatus,
    this.image,
  });

  factory CustomerInfo.fromMap(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      email: json['email'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      phone: json['phone'],
      gender: json['gender'],
      dob: json['dob'],
      highestEducation: json['highest_education'],
      religion: json['religion']?.toString(),
      children: json['children']?.toString(),
      oldestChild: json['oldest_child']?.toString(),
      spouseName: json['spouse_name'],
      haveSpouseOccupation: json['have_spouse_occupation']?.toString(),
      haveChildren: json['have_children']?.toString(),
      spouseOccupation: json['spouse_occupation'],
      maritalStatus: json['marital_status'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'father_name': fatherName,
      'mother_name': motherName,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'highest_education': highestEducation,
      'religion': religion,
      'children': children,
      'oldest_child': oldestChild,
      'spouse_name': spouseName,
      'have_spouse_occupation': haveSpouseOccupation,
      'have_children': haveChildren,
      'spouse_occupation': spouseOccupation,
      'marital_status': maritalStatus,
      'image': image,
    };
  }
}

class LoanSimDetails {
  final String? status;
  final String? loanaccount;
  final String? branch;
  final String? product;
  final String? currency;
  final String? custid;
  final String? interestRate;
  final String? emiValue;
  final String? cibChargeTotal;
  final String? cibChargeValue;
  final String? cibChargeVat;
  final String? processingFeeTotal;
  final String? processingFeeValue;
  final String? processingFeeVat;
  final String? errordescription;
  final String? valueDate;
  final String? maturityDate;
  final String? loanamount;

  LoanSimDetails({
    this.status,
    this.loanaccount,
    this.branch,
    this.product,
    this.currency,
    this.custid,
    this.interestRate,
    this.emiValue,
    this.cibChargeTotal,
    this.cibChargeValue,
    this.cibChargeVat,
    this.processingFeeTotal,
    this.processingFeeValue,
    this.processingFeeVat,
    this.errordescription,
    this.valueDate,
    this.maturityDate,
    this.loanamount,
  });

  factory LoanSimDetails.fromMap(Map<String, dynamic> json) {
    return LoanSimDetails(
      status: json['status']?.toString(),
      loanaccount: json['loanaccount']?.toString(),
      branch: json['branch']?.toString(),
      product: json['product']?.toString(),
      currency: json['currency']?.toString(),
      custid: json['custid']?.toString(),
      interestRate: json['interestRate']?.toString(),
      emiValue: json['emiValue']?.toString(),
      cibChargeTotal: json['ciB_Charge_Total']?.toString(),
      cibChargeValue: json['ciB_Charge_Value']?.toString(),
      cibChargeVat: json['ciB_Charge_VAT']?.toString(),
      processingFeeTotal: json['processing_Fee_Total']?.toString(),
      processingFeeValue: json['processing_Fee_Value']?.toString(),
      processingFeeVat: json['processing_Fee_VAT']?.toString(),
      errordescription: json['errordescription']?.toString(),
      valueDate: json['valueDate']?.toString(),
      maturityDate: json['maturityDate']?.toString(),
      loanamount: json['loanamount']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'loanaccount': loanaccount,
      'branch': branch,
      'product': product,
      'currency': currency,
      'custid': custid,
      'interestRate': interestRate,
      'emiValue': emiValue,
      'ciB_Charge_Total': cibChargeTotal,
      'ciB_Charge_Value': cibChargeValue,
      'ciB_Charge_VAT': cibChargeVat,
      'processing_Fee_Total': processingFeeTotal,
      'processing_Fee_Value': processingFeeValue,
      'processing_Fee_VAT': processingFeeVat,
      'errordescription': errordescription,
      'valueDate': valueDate,
      'maturityDate': maturityDate,
      'loanamount': loanamount,
    };
  }
}

class Product {
  final int? id;
  final String? uuid;
  final int? companyId;
  final String? productIdentity;
  final String? phoneName;
  final String? model;
  final List<int>? color;
  final String? brandId;
  final String? brandName;
  final String? stockStatus;
  final String? description;
  final int? categoryId;
  final List<ProductFile>? file;

  Product({
    this.id,
    this.uuid,
    this.companyId,
    this.productIdentity,
    this.phoneName,
    this.model,
    this.color,
    this.brandId,
    this.brandName,
    this.stockStatus,
    this.description,
    this.categoryId,
    this.file,
  });

  factory Product.fromMap(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      uuid: json['uuid'],
      companyId: json['company_id'],
      productIdentity: json['product_identity']?.toString(),
      phoneName: json['phone_name'],
      model: json['model'],
      color: json['color'] != null ? List<int>.from(json['color']) : null,
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name'],
      stockStatus: json['stock_status']?.toString(),
      description: json['description'],
      categoryId: json['category_id'],
      file: json['file'] != null
          ? (json['file'] as List).map((e) => ProductFile.fromMap(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'company_id': companyId,
      'product_identity': productIdentity,
      'phone_name': phoneName,
      'model': model,
      'color': color,
      'brand_id': brandId,
      'brand_name': brandName,
      'stock_status': stockStatus,
      'description': description,
      'category_id': categoryId,
      'file': file?.map((e) => e.toMap()).toList(),
    };
  }
}

class ProductFile {
  final int? id;
  final String? uuid;
  final String? fileName;
  final String? ext;
  final String? path;
  final int? productId;

  ProductFile(
      {this.id,
        this.uuid,
        this.fileName,
        this.ext,
        this.path,
        this.productId});

  factory ProductFile.fromMap(Map<String, dynamic> json) {
    return ProductFile(
      id: json['id'],
      uuid: json['uuid'],
      fileName: json['file_name'],
      ext: json['ext'],
      path: json['path'],
      productId: json['product_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'file_name': fileName,
      'ext': ext,
      'path': path,
      'product_id': productId,
    };
  }
}

class ProductInfo {
  final int? id;
  final String? uuid;
  final int? companyId;
  final String? productIdentity;
  final String? phoneName;
  final String? model;
  final List<int>? color;
  final String? specification;
  final String? brandId;
  final String? brandName;
  final String? stockStatus;
  final String? description;
  final int? categoryId;
  final List<ProductFileInfo>? file;

  ProductInfo({
    this.id,
    this.uuid,
    this.companyId,
    this.productIdentity,
    this.phoneName,
    this.model,
    this.color,
    this.specification,
    this.brandId,
    this.brandName,
    this.stockStatus,
    this.description,
    this.categoryId,
    this.file,
  });

  factory ProductInfo.fromMap(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'],
      uuid: json['uuid'],
      companyId: json['company_id'],
      productIdentity: json['product_identity']?.toString(),
      phoneName: json['phone_name'],
      model: json['model'],
      color: json['color'] != null ? List<int>.from(json['color']) : null,
      specification: json['specification']?.toString(),
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name'],
      stockStatus: json['stock_status']?.toString(),
      description: json['description'],
      categoryId: json['category_id'],
      file: json['file'] != null
          ? (json['file'] as List)
          .map((e) => ProductFileInfo.fromMap(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'company_id': companyId,
      'product_identity': productIdentity,
      'phone_name': phoneName,
      'model': model,
      'color': color,
      'brand_id': brandId,
      'brand_name': brandName,
      'stock_status': stockStatus,
      'description': description,
      'category_id': categoryId,
      'file': file?.map((e) => e.toMap()).toList(),
    };
  }
}

class ProductFileInfo {
  final int? id;
  final String? uuid;
  final String? fileName;
  final String? ext;
  final String? path;
  final int? productId;

  ProductFileInfo({
    this.id,
    this.uuid,
    this.fileName,
    this.ext,
    this.path,
    this.productId,
  });

  factory ProductFileInfo.fromMap(Map<String, dynamic> json) {
    return ProductFileInfo(
      id: json['id'],
      uuid: json['uuid'],
      fileName: json['file_name'],
      ext: json['ext'],
      path: json['path'],
      productId: json['product_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'file_name': fileName,
      'ext': ext,
      'path': path,
      'product_id': productId,
    };
  }
}