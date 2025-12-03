import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VerificationCodeScreen extends StatefulWidget {
  final String email; // or phone number
  final String verificationId; // from your backend

  const VerificationCodeScreen({
    super.key,
    required this.email,
    this.verificationId = '',
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isVerifying = false;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Add listeners to auto-focus next field
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.isNotEmpty && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 6;
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete()) {
      _showSnackBar('Please enter complete 6-digit code', Colors.red);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final code = _getCode();

      // TODO: Replace with your actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      // Example API call structure:
      // final response = await http.post(
      //   Uri.parse('YOUR_API_URL/verify-code'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'email': widget.email,
      //     'code': code,
      //     'verificationId': widget.verificationId,
      //   }),
      // );

      // For demo purposes, let's say code is valid if it's "123456"
      if (code == "123456") {
        _showSnackBar('Verification successful!', Colors.green);

        // Navigate to next screen
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home'); // Replace with your route
        }
      } else {
        _showSnackBar('Invalid verification code', Colors.red);
        _clearCode();
      }
    } catch (e) {
      _showSnackBar('Verification failed: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() => _isVerifying = true);

    try {
      // TODO: Replace with your actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call

      // Example API call structure:
      // await http.post(
      //   Uri.parse('YOUR_API_URL/resend-code'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'email': widget.email}),
      // );

      _showSnackBar('Verification code resent!', Colors.green);
      _clearCode();
      _startTimer();
    } catch (e) {
      _showSnackBar('Failed to resend code: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/al_sharq_logo.png', // Make sure to add this asset
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),

                      // Title
                      const Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Please enter the 6-digit code sent to your email\nor phone',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Code Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return _buildCodeField(index);
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isVerifying || !_isCodeComplete()
                              ? null
                              : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B1538),
                            disabledBackgroundColor: const Color(0xFF8B1538).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Resend Code Section
                      _buildResendSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(int index) {
    return Container(
      width: 45,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? const Color(0xFF8B1538)
              : Colors.grey[300]!,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // Update button state
        },
        onTap: () {
          setState(() {}); // Update border color
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _canResend ? 'Didn\'t receive code?' : 'Resend code in',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        if (_canResend)
          GestureDetector(
            onTap: _isVerifying ? null : _resendCode,
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                color: _isVerifying ? Colors.grey : const Color(0xFF8B1538),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1538).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B1538),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}