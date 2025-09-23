import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';



class QRPassScreen extends StatefulWidget {
  const QRPassScreen({super.key});

  @override
  State<QRPassScreen> createState() => _QRPassScreenState();
}

class _QRPassScreenState extends State<QRPassScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshQRCode() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code refreshed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code downloaded to gallery'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,

        title: AppText(
          text: 'My QR Pass',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Main QR Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mediumGreyColor,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Name and Details
                    AppText(
                      text: 'Dr. Johnathan',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(height: 4),
                    AppText(
                      text: 'Al Sharq University',
                      fontSize: 16,
                      color: AppColors.darkgrey,
                    ),
                    SizedBox(height: 4),
                    AppText(
                      text: 'Attendee',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                    SizedBox(height: 24),

                    // QR Code
                    Container(
                      width: isTablet ? 200 : 180,
                      height: isTablet ? 200 : 180,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.mediumGreyColor,
                          width: 1,
                        ),
                      ),
                      child: _isRefreshing
                          ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                          : _buildQRCodePattern(),
                    ),
                    SizedBox(height: 16),

                    // QR Instructions
                    AppText(
                      text: 'Show this QR code at check-in',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status Row
                    _buildDetailRow(
                      'Status',
                      '',
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AppText(
                          text: 'Active',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    Divider(color: AppColors.lightGreyColor, height: 24),

                    // Badge ID
                    _buildDetailRow('Badge ID', 'AS2025-1034'),

                    Divider(color: AppColors.lightGreyColor, height: 24),

                    // Role
                    _buildDetailRow('Role / Designation', 'Attendee - Al Sharq University'),

                    Divider(color: AppColors.lightGreyColor, height: 24),

                    // Location
                    _buildDetailRow('Location', 'Doha, Qatar'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              CustomButton(
                text: 'Download QR Code',
              //  icon: Icons.download,
                onPressed: _downloadQRCode,
                backgroundColor: AppColors.primaryColor,
                height: 50,
              ),

              SizedBox(height: 12),

              CustomButton(
                text: 'Refresh QR Code',
              //  icon: Icons.refresh,
                onPressed: _refreshQRCode,
              //  isOutlined: true,
                isLoading: _isRefreshing,
                height: 50,
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: AppText(
            text: label,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ),
        SizedBox(width: 16),
        trailing ??
            Expanded(
              flex: 3,
              child: AppText(
                text: value,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
                textAlign: TextAlign.end,
              ),
            ),
      ],
    );
  }

  Widget _buildQRCodePattern() {
    // Simulated QR code pattern using containers
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 21,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: 441, // 21x21 grid
        itemBuilder: (context, index) {
          // Create a pattern that looks like a QR code
          bool shouldFill = _getQRPattern(index);

          return Container(
            decoration: BoxDecoration(
              color: shouldFill ? AppColors.blackColor : AppColors.whiteColor,
            ),
          );
        },
      ),
    );
  }

  bool _getQRPattern(int index) {
    // This creates a simplified QR-like pattern
    int row = index ~/ 21;
    int col = index % 21;

    // Corner squares (position detection patterns)
    if ((row < 7 && col < 7) ||
        (row < 7 && col > 13) ||
        (row > 13 && col < 7)) {
      return _isInCornerPattern(row % 7, col % 7);
    }

    // Timing patterns
    if (row == 6 || col == 6) {
      return (row + col) % 2 == 0;
    }

    // Random pattern for data area
    return (row * col + row + col) % 3 == 0;
  }

  bool _isInCornerPattern(int row, int col) {
    // 7x7 corner pattern
    if (row == 0 || row == 6 || col == 0 || col == 6) return true;
    if (row >= 2 && row <= 4 && col >= 2 && col <= 4) return true;
    return false;
  }
}