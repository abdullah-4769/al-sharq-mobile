import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';

import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class ConferenceScheduleScreen extends StatelessWidget {
   ConferenceScheduleScreen({super.key});
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: "Conference Schedule",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: "Search",
                    controller: searchController,
                    suffixIcon: Icons.search,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 50,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(Icons.tune, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "My Agenda",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4),
                      AppText(
                        text: "2 sessions bookmarked",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🗓 Day Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                AppText(
                  text: "Monday, Feb 10, 2025",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: "View All",
                  fontSize: 14,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📌 Session Card
            _buildSessionCard(
              title: "The Future of Regional Cooperation",
              speaker: "Prof. Omar Khalil",
              time: "10:00 AM – 11:30 AM",
              duration: "90 minutes",
              room: "Hall B",
              tag: "Panel",
              tagColor: Colors.yellow[700]!,
            ),
            const SizedBox(height: 20),

            // 🗓 Next Day
            const AppText(
              text: "Tuesday, Feb 11, 2025",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),

            _buildSessionCard(
              title: "Digital Transformation in MENA",
              speaker: "Dr. Sarah Hassan +2 more",
              time: "2:00 PM – 3:30 PM",
              duration: "90 minutes",
              room: "Hall C",
              tag: "Keynote",
              tagColor: AppColors.darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Session Card
  Widget _buildSessionCard({
    required String title,
    required String speaker,
    required String time,
    required String duration,
    required String room,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.bookmark_border, color: AppColors.primaryColor),
            ],
          ),
          const SizedBox(height: 6),

          // Speaker
          AppText(
            text: speaker,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),

          // Time + Tag
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: 6),
              AppText(text: time, fontSize: 14, color: AppColors.darkgrey),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  text: tag,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: tagColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Duration + Room
          Row(
            children: [
              const AppText(
                text: "Duration",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(width: 6),
              AppText(text: duration, fontSize: 14, color: AppColors.darkgrey),
              const SizedBox(width: 24),
              const AppText(
                text: "Room",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(width: 6),
              AppText(text: room, fontSize: 14, color: AppColors.darkgrey),
            ],
          ),
          const SizedBox(height: 16),

          // 🔘 Button
          CustomButton(
            text: "View Details",
            onPressed: () {},
            height: 44,
          ),
        ],
      ),
    );
  }
}
