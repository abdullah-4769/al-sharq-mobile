import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/images/images.dart';

import '../../../custom_widgets/app_text.dart';

class CustomSessionDetail extends StatelessWidget {
  const CustomSessionDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Session Details ----
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Session Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                "Key Topics",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // ✅ Chips in 2 rows
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildChip("Economic Integration")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildChip("Digital Cooperation")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildChip("Regional Security")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildChip("Trade Partnerships")),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "Target Audience",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              const Text(
                "Government officials, policy makers, business leaders, and researchers interested in regional cooperation and economic development.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text(
                "Language",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              const Text(
                "English with Arabic translation available",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ---- Who's Attending ----
        const Text(
          "Who's Attending",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 36,
                child: Stack(
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 24.0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: AssetImage(Images.drjohnthan),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "342 registered attendees",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ---- Buttons ----
        _buildButton(
          icon: Icons.notifications,
          label: "Set Reminder",
          color: Colors.grey.shade100,
          textColor: Colors.black87,
        ),
        const SizedBox(height: 12),
        _buildButton(
          icon: Icons.calendar_today,
          label: "Add to Calendar",
          color: Colors.grey.shade100,
          textColor: Colors.black87,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: "I’m Attending",
          color: AppColors.primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }

  // Helper widget for Chips
  static Widget _buildChip(String text) {
    return Chip(
      label: AppText(
        text:
        text,
        color:AppColors.primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      backgroundColor: AppColors.lightred,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Helper widget for Buttons
  Widget _buildButton({
    required String label,
    IconData? icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
          ],
          AppText(
            text:
            label,

              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),

        ],
      ),
    );
  }
}
