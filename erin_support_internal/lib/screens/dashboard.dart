import 'package:flutter/material.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';
import 'package:erin_support_internal/widgets/bottomBar.dart';
import 'package:erin_support_internal/screens/balance.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<ApiResponse?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = Save.getUser();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: false,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color:  const Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Color(0xFF0F172A), size: 20),
            ),
            onPressed: () async {
              await Save.clearUser();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },

          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<ApiResponse?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: Text("No user data found."));
          }

          final response = snapshot.data!;
          final data = response.data!;
          final cib = data.cib ?? "Null";
          final profee = data.profee ?? "Null";
          final tcsa = data.tcsa ?? "Null";
          final customer = data.customerInfo;
          final product = data.product!;
          final dms = data.dmsInfo;
          final mdm = data.mdmInfo;
          final downPayment = data.downPaymentInfo;
          final emiPayable = data.emiPayableInfo;
          final creditScore = data.creditScoreInfo;
          final loanCreation = data.loanCreationDetails;
          final loanSchedule = data.loanCreationDetails?.emischedule;
          final emiSchedules = data.emiInfo;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 0. Profile Banner Header
              _buildProfileHeader(customer, profee, cib!, tcsa!, data.status),
              const SizedBox(height: 20),

              // Overview Cards Row (Credit Score & Current Loan)
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      title: "CREDIT SCORE",
                      mainValue: creditScore?.finalScore?.toString() ?? 'N/A',
                      subtitle: creditScore?.finalScore != null
                          ? (creditScore!.finalScore! > 70
                          ? 'Good'
                          : creditScore.finalScore! > 50
                          ? 'Fair'
                          : 'Low')
                          : 'N/A',
                      progress: (creditScore?.finalScore ?? 0) / 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      title: "CURRENT LOAN",
                      mainValue: product?.model ?? product?.phoneName ?? 'N/A',
                      subtitle:
                      "EMI: ${emiPayable?.monthlyAmount != null ? 'BDT ${emiPayable?.monthlyAmount}' : 'N/A'}",
                      accountInfo: loanCreation?.loanaccno != null
                          ? "Acc: ...${loanCreation!.loanaccno!.length > 4 ? loanCreation.loanaccno!.substring(loanCreation.loanaccno!.length - 4) : loanCreation.loanaccno}"
                          : "Acc: N/A",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SUPPORT SECTION
              const Text(
                "SUPPORT & FINANCIALS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildPreferenceTile(
                      icon: Icons.info_outline,
                      title: "General & Session Info",
                      subtitle: "Application ID: ${data.applicationId ?? 'N/A'}",
                      onTap: () {
                        _showDetailsBottomSheet("General & Session Info", [
                          _buildRow("Application ID", data.applicationId),
                          _buildRow("User Ref No", data.userRefNo),
                          _buildRow("Bank ID", data.bankId),
                          _buildRow("Created At", data.createdAt),
                        ]);
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Financials & Down Payment",
                      subtitle: downPayment?.totalDownPayment != null
                          ? "Total DP: ${downPayment?.totalDownPayment}"
                          : "View breakdown & charges",
                      onTap: () {
                        _showDetailsBottomSheet("Financials & Down Payment", [
                          _buildRow("Down Payment", downPayment?.downPayment),
                          _buildRow("Processing Fee", downPayment?.processingFee),
                          _buildRow("CIB Charge", downPayment?.cibCharge),
                          _buildRow("Total Down Payment", downPayment?.totalDownPayment),
                          _buildDivider(),
                          _buildRow("EMI Duration", emiPayable?.emiDuration),
                          _buildRow("Initial Amount", emiPayable?.initialAmount),
                          _buildRow("Total Amount", emiPayable?.totalAmount),
                          _buildRow(
                              "Interest Rate",
                              emiPayable?.interestRate != null
                                  ? "${emiPayable?.interestRate}%"
                                  : 'N/A'),
                          _buildRow("Monthly Amount", emiPayable?.monthlyAmount),
                        ]);
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceTile(
                      icon: Icons.calendar_today_outlined,
                      title: "EMI Schedule List",
                      subtitle: "${emiSchedules?.length ?? 0} schedules available",
                      onTap: () {
                        _showDetailsBottomSheet(
                          "EMI Schedule",
                          emiSchedules != null && emiSchedules.isNotEmpty
                              ? emiSchedules
                              .map((schedule) => Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Text(
                                  "${schedule.scheduleNumber ?? ''}",
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                "Date: ${schedule.scheduleDate ?? 'N/A'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              subtitle: Text(
                                "Amount: ${schedule.emiAmount ?? 'N/A'}",
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (schedule.status
                                      ?.toLowerCase() ==
                                      'paid')
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (schedule.status
                                        ?.toLowerCase() ==
                                        'paid')
                                        ? Colors.green.shade300
                                        : Colors.orange.shade300,
                                  ),
                                ),
                                child: Text(
                                  schedule.status ?? 'unpaid',
                                  style: TextStyle(
                                    color: (schedule.status
                                        ?.toLowerCase() ==
                                        'paid')
                                        ? Colors.green.shade700
                                        : Colors.orange.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ))
                              .toList()
                              : [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No EMI schedule found.",
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          ],
                        );
                      },
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ACCOUNT & PREFERENCES SECTION
              const Text(
                "ACCOUNT & PREFERENCES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildPreferenceTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Loan Creation Details",
                      subtitle:
                      "${loanCreation?.statusdescription ?? 'Active'} • ${emiPayable?.emiDuration ?? 'N/A'} • ${emiPayable?.totalAmount != null ? 'BDT ${emiPayable?.totalAmount}' : 'N/A'}",
                      onTap: () {
                        _showDetailsBottomSheet("Loan Creation Details", [
                          _buildRow("Status Code", loanCreation?.statuscode),
                          _buildRow("Status Description", loanCreation?.statusdescription),
                          _buildRow("Loan Account No", loanCreation?.loanaccno),
                          _buildRow("Branch", loanCreation?.brn),
                          _buildRow("Currency", loanCreation?.ccy),
                          _buildRow("Amount Financed", loanCreation?.amtfinanced),
                          _buildRow("Value Date", loanCreation?.valdt),
                          _buildRow("Maturity Date", loanCreation?.matdt),
                          _buildRow("EMI Collection AC", loanCreation?.emicollectionAc),
                          const SizedBox(height: 12),
                          const Text(
                            "LOAN SCHEDULE",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (loanSchedule != null && loanSchedule.isNotEmpty)
                            ...loanSchedule.map((schedule) =>
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFEFF6FF),
                                      child: Text(
                                        "${schedule.scheduleNumber ?? ''}",
                                        style: const TextStyle(
                                            color: Color(0xFF2563EB),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      "Date: ${schedule.scheduleDate ?? 'N/A'}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    subtitle: Text(
                                      "Amount: ${schedule.emiAmount ?? 'N/A'}",
                                      style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13),
                                    ),
                                  ),
                                ))

                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Center(
                                child: Text("No loan schedule found.",
                                    style: TextStyle(color: Color(0xFF64748B))),
                              ),
                            ),
                        ]);
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceTile(
                      icon: Icons.person_outline,
                      title: "Customer Information",
                      subtitle: customer?.phone ?? 'View personal profile info',
                      onTap: () {
                        _showDetailsBottomSheet("Customer Information", [
                          _buildRow("Phone", customer?.phone),
                          _buildRow("Email", customer?.email),
                          _buildRow("Father's Name", customer?.fatherName),
                          _buildRow("Mother's Name", customer?.motherName),
                          _buildRow("Gender", customer?.gender),
                          _buildRow("DOB", customer?.dob),
                          _buildRow("Marital Status", customer?.maritalStatus),
                          _buildRow("Education", customer?.highestEducation),
                          _buildRow("Religion", customer?.religion),
                          _buildRow("Have Children", customer?.haveChildren),
                        ]);
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceTile(
                      icon: Icons.phone_android_outlined,
                      title: "Product Details",
                      subtitle: product?.phoneName ?? 'View product & specifications',
                      onTap: () {
                        _showDetailsBottomSheet("Product Details", [
                          _buildRow("Phone Name", product?.phoneName),
                          _buildRow("Model", product?.model),
                          _buildRow("Product Identity", product?.productIdentity),
                          _buildRow("Brand Name", product?.brandName),
                          _buildRow("Stock Status", product?.stockStatus),
                          _buildRow(
                              "Description",
                              product?.description != null
                                  ? "Available"
                                  : "N/A"),
                        ]);
                      },
                    ),
                    _buildDivider(),
                    _buildPreferenceTile(
                      icon: Icons.store_outlined,
                      title: "DMS & MDM Info",
                      subtitle: dms?.storeName ?? 'View store & device binding',
                      onTap: () {
                        _showDetailsBottomSheet("DMS & MDM Info", [
                          _buildRow("DMS ID", dms?.dmsId),
                          _buildRow("Store Name", dms?.storeName),
                          _buildRow("TCSA Name", dms?.tcsaName),
                          _buildRow("Partner", dms?.partner),
                          _buildRow("Category", dms?.category),
                          _buildDivider(),
                          _buildRow("MDM Customer ID", mdm?.customerId),
                          _buildRow("IMEI 1", mdm?.imei1),
                          _buildRow("IMEI 2", mdm?.imei2),
                          _buildRow("MDM Down Payment", mdm?.downPayment),
                        ]);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),





              // Version Footer
              const Center(
                child: Text(
                  "Erin Support v1.0.0",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  void _showDetailsBottomSheet(String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileHeader(
      CustomerInfo? customer, String? profee, String cib, String tcsa, String? status) {

    bool isProfeeTrue = profee?.toLowerCase() == 'true' || profee == '1';
    bool isCibTrue = cib.toLowerCase() == 'true' || cib == '1';
    bool isTcsaTrue = tcsa.toLowerCase() == 'true' || tcsa == '1';

    Color getStatusColor(bool value) {
      return value ? Colors.green.shade700 : Colors.red.shade700;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Sub-header text matching the design

        const SizedBox(height: 2),

        // Main Blue Card Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A), // Deep rich blue
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title + Visibility Icon

              // Amount & Percentage Row
              const SizedBox(height: 16),

              // Customer Info Sub-section inside the Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      (customer?.image != null && customer!.image!.isNotEmpty)
                          ? NetworkImage(customer.image!)
                          : null,
                      child: (customer?.image == null || customer!.image!.isEmpty)
                          ? const Icon(Icons.person, size: 20, color: Color(0xFF1E3A8A))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.name ?? 'Unknown Customer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Status: ${status ?? '0'} • ${ customer?.phone ?? 'No Contact'}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Profee, CIB, TCSA Pills inside the White Overlay Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusPill(
                      label: "Profee",
                      statusText: profee ?? 'N/A',
                      isTrue: isProfeeTrue,
                      color: getStatusColor(isProfeeTrue),
                    ),
                    Container(height: 20, width: 1, color: Colors.grey.shade200),
                    _buildStatusPill(
                      label: "CIB",
                      statusText: cib,
                      isTrue: isCibTrue,
                      color: getStatusColor(isCibTrue),
                    ),
                    Container(height: 20, width: 1, color: Colors.grey.shade200),
                    _buildStatusPill(
                      label: "TCSA",
                      statusText: tcsa,
                      isTrue: isTcsaTrue,
                      color: getStatusColor(isTcsaTrue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required String label,
    required String statusText,
    required bool isTrue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTrue ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTrue ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTrue ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            "$label: $statusText",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildOverviewCard({
    required String title,
    required String mainValue,
    required String subtitle,
    double? progress,
    String? accountInfo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainValue,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 8),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                minHeight: 6,
              ),
            )
          else if (accountInfo != null)
            Text(
              accountInfo,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: const Color(0xFFF1F5F9), height: 1, thickness: 1);
  }
}