import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/others/save.dart';

class ZTEUnlock extends StatefulWidget {
  const ZTEUnlock({super.key});

  @override
  State<ZTEUnlock> createState() => _ZTEUnlockState();
}

class _ZTEUnlockState extends State<ZTEUnlock> {
  bool isLoading = false;

  String? token;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }


  Future<void> _loadUser() async {
    try {
      final user = await Save.getUser();

      if (user != null) {
        setState(() {
          token = user.token;
        });
      }
    } catch (e) {
      debugPrint('Load user error: $e');
    }
  }



  Widget _buildMdmCard() {
    return FutureBuilder(
      future: Save.getUser(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }


        if (snapshot.hasError) {
          return _buildMdmErrorCard();
        }


        if (!snapshot.hasData || snapshot.data == null) {
          return _buildMdmErrorCard();
        }

        final user = snapshot.data;

        if (user == null || user.data == null) {
          return _buildMdmErrorCard();
        }

        final customer = user.data!;


        final String imei1 =
            customer.mdmInfo?.imei1?.toString() ?? '';

        final String imei2 =
            customer.mdmInfo?.imei2?.toString() ?? '';

        debugPrint('UI IMEI 1: $imei1');
        debugPrint('UI IMEI 2: $imei2');


        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Unlock ZTE phone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildImeiField(
                label: 'IMEI 1',
                value: imei1,
              ),




              const SizedBox(height: 20),



              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : updateMdmInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    Colors.blue.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Unlock Phone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildImeiField({
    required String label,
    required String value,
  }) {
    final bool hasValue = value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 7),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sim_card_outlined,
                size: 20,
                color: Colors.grey,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  hasValue ? value : 'Not available',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasValue
                        ? Colors.black87
                        : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildMdmErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 40,
          ),

          const SizedBox(height: 10),

          const Text(
            'Device information not available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Unable to load IMEI information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }



  Future<void> updateMdmInfo() async {


    final user = await Save.getUser();

    if (user == null) {
      _showError('Customer information not found');
      return;
    }

    if (user.data == null) {
      _showError('Customer data not found');
      return;
    }

    final customer = user.data!;


    final String savedToken =
        user.token?.toString() ?? '';

    if (savedToken.isEmpty) {
      _showError('Token not found');
      return;
    }


    final String imei1 =
        customer.mdmInfo?.imei1?.toString() ?? '';

    debugPrint('IMEI 1: $imei1');

    if (imei1.isEmpty) {
      _showError('IMEI 1 not found');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Uri url = Uri.parse(
        'https://vdmsmbb.ztems.com/vdms20/api/north/unlock',
      );

      const String accessKeyId = 'Dhaka.Bank';

      const String secretKey =
          'ae56677a5e5ff300a33df15714ff4452';



      final timestamp =
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      final body = jsonEncode({
        'imei': imei1,
      });

      final signString =
          'accessKeyId=$accessKeyId'
          '&timestamp=$timestamp'
          '&body=$body'
          '&$secretKey';

      final signature =
      md5.convert(utf8.encode(signString)).toString();

      print('Timestamp: $timestamp');
      print('Body: $body');
      print('SignString: $signString');
      print('Signature: $signature');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-access-key-id': accessKeyId,
          'x-api-timestamp': timestamp,
          'x-api-signature': signature,
        },
        body: body,
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      debugPrint('========== UNLOCK RESPONSE =========');
      debugPrint('Body: ${body}');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('====================================');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showSuccess(
          'Success! Unlocked ZTE phone!',
        );
      } else {
        String message = 'Failed to unlock';

        try {
          final dynamic responseData =
          jsonDecode(response.body);

          if (responseData is Map<String, dynamic>) {
            message =
                responseData['message']?.toString() ??
                    responseData['error']?.toString() ??
                    message;
          }
        } catch (_) {
          // Keep default message
        }

        _showError(
          '$message (${response.statusCode})',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========== UNLOCK ERROR =============');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('====================================');

      _showError(
        'Something went wrong: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildMdmCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}