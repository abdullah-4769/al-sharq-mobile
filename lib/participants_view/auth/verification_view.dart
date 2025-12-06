import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/forget_password_viewmodel/forget_pass_viewmodel.dart';


// ==================== OTP VERIFICATION SCREEN ====================
/// Screen for verifying OTP code sent to user's email

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final OTPVerificationController controller = Get.put(OTPVerificationController());
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await SharedPrefsHelper.getPassResetEmail();
    setState(() {
      userEmail = email ?? 'your email';
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/al_sharq_logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.account_balance, color: Colors.white);
              },
            ),
            SizedBox(width: 10),
            Text('Al Sharq Conference'),
          ],
        ),
        backgroundColor: Color(0xFF9B2033),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // ==================== HEADER SECTION ====================
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF9B2033).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline,
                size: 60,
                color: Color(0xFF9B2033),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B2033),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Enter the 6-digit code sent to',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // ==================== OTP INPUT SECTION ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9B2033), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      controller.updateOTPDigit(index, value);

                      if (value.isNotEmpty && index < 5) {
                        focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 30),

            // ==================== COUNTDOWN TIMER SECTION ====================
            Obx(() => controller.countdown.value > 0
                ? Text(
              'Resend code in ${controller.countdown.value}s',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            )
                : SizedBox()),
            SizedBox(height: 20),

            // ==================== ERROR MESSAGE SECTION ====================
            Obx(() => controller.errorMessage.value.isNotEmpty
                ? Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox()),
            SizedBox(height: 30),

            // ==================== VERIFY BUTTON SECTION ====================
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B2033),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
            SizedBox(height: 20),

            // ==================== RESEND CODE SECTION ====================
            Obx(() => TextButton(
              onPressed: controller.canResend.value && !controller.isLoading.value
                  ? controller.resendOTP
                  : null,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: controller.canResend.value
                      ? Color(0xFF9B2033)
                      : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            )),
            SizedBox(height: 10),

            // ==================== BACK BUTTON SECTION ====================
            TextButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
              label: Text(
                'Back',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
// import '../../utils/shared_preference.dart';
// import '../../view_model/forget_password_viewmodel/forget_pass_viewmodel.dart';
//
//
// // ==================== OTP VERIFICATION SCREEN ====================
// /// Screen for verifying OTP code sent to user's email
//
// class OTPVerificationScreen extends StatefulWidget {
//   const OTPVerificationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
// }
//
// class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final OTPVerificationController controller = Get.put(OTPVerificationController());
//   final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
//   String userEmail = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadEmail();
//   }
//
//   Future<void> _loadEmail() async {
//     final email = await SharedPrefsHelper.getPassResetEmail();
//     setState(() {
//       userEmail = email ?? 'your email';
//     });
//   }
//
//   @override
//   void dispose() {
//     for (var controller in otpControllers) {
//       controller.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Image.asset(
//               'assets/al_sharq_logo.png',
//               height: 40,
//               errorBuilder: (context, error, stackTrace) {
//                 return Icon(Icons.account_balance, color: Colors.white);
//               },
//             ),
//
//           ],
//         ),
//         backgroundColor: Color(0xFF9B2033),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 20),
//
//             // ==================== HEADER SECTION ====================
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Color(0xFF9B2033).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.mail_outline,
//                 size: 60,
//                 color: Color(0xFF9B2033),
//               ),
//             ),
//             SizedBox(height: 30),
//             Text(
//               'Verify Your Email',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF9B2033),
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Enter the 6-digit code sent to',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8),
//             Text(
//               userEmail,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 40),
//
//             // ==================== OTP INPUT SECTION ====================
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(6, (index) {
//                 return SizedBox(
//                   width: 50,
//                   height: 60,
//                   child: TextField(
//                     controller: otpControllers[index],
//                     focusNode: focusNodes[index],
//                     textAlign: TextAlign.center,
//                     maxLength: 1,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     decoration: InputDecoration(
//                       counterText: '',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Color(0xFF9B2033), width: 2),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                     onChanged: (value) {
//                       controller.updateOTPDigit(index, value);
//
//                       if (value.isNotEmpty && index < 5) {
//                         focusNodes[index + 1].requestFocus();
//                       } else if (value.isEmpty && index > 0) {
//                         focusNodes[index - 1].requestFocus();
//                       }
//                     },
//                   ),
//                 );
//               }),
//             ),
//             SizedBox(height: 30),
//
//             // ==================== COUNTDOWN TIMER SECTION ====================
//             Obx(() => controller.countdown.value > 0
//                 ? Text(
//               'Resend code in ${controller.countdown.value}s',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             )
//                 : SizedBox()),
//             SizedBox(height: 20),
//
//             // ==================== ERROR MESSAGE SECTION ====================
//             Obx(() => controller.errorMessage.value.isNotEmpty
//                 ? Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.red, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       controller.errorMessage.value,
//                       style: TextStyle(color: Colors.red[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : SizedBox()),
//             SizedBox(height: 30),
//
//             // ==================== VERIFY BUTTON SECTION ====================
//             Obx(() => SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: controller.isLoading.value ? null : controller.verifyOTP,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF9B2033),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                 ),
//                 child: controller.isLoading.value
//                     ? SizedBox(
//                   height: 24,
//                   width: 24,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2.5,
//                   ),
//                 )
//                     : Text(
//                   'Verify Code',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             )),
//             SizedBox(height: 20),
//
//             // ==================== RESEND CODE SECTION ====================
//             Obx(() => TextButton(
//               onPressed: controller.canResend.value && !controller.isLoading.value
//                   ? controller.resendOTP
//                   : null,
//               child: Text(
//                 'Resend Code',
//                 style: TextStyle(
//                   color: controller.canResend.value
//                       ? Color(0xFF9B2033)
//                       : Colors.grey,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//             )),
//             SizedBox(height: 10),
//
//             // ==================== BACK BUTTON SECTION ====================
//             TextButton.icon(
//               onPressed: () => Get.back(),
//               icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
//               label: Text(
//                 'Back',
//                 style: TextStyle(
//                   color: Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }