import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';


class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.analytics, color: AppColors.white, size: 20),
        ),
        title: AppText(
          text: 'AL SHARQ CONFERENCE',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkgrey,
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=2'),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: AppColors.lightGrey),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(Icons.tune, color: AppColors.primaryColor),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(),

            SizedBox(height: 24),

            // Most Popular Sessions
            _buildMostPopularSessions(),

            SizedBox(height: 24),

            // Engagement Metrics Chart
            _buildEngagementChart(),

            SizedBox(height: 24),

            // Demographics Section
            _buildDemographicsSection(),

            SizedBox(height: 24),

            // Recent Participants
            _buildRecentParticipants(),

            SizedBox(height: 24),

            // Export Report Button
            CustomButton(
              text: 'Export Report',
              onPressed: _exportReport,
              backgroundColor: AppColors.primaryColor,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Total Registrations', '1,250', Icons.people, AppColors.chartColor3),
        _buildStatCard('Checked In Today', '830', Icons.login, AppColors.successColor),
        _buildStatCard('Active Sessions', '5', Icons.play_circle, AppColors.chartColor5),
        _buildStatCard('Total Speakers', '205', Icons.mic, AppColors.warningColor),
        _buildStatCard('Total Sponsors', '455', Icons.business, AppColors.chartColor6),
        _buildStatCard('Total Participants', '1,850', Icons.group, AppColors.primaryColor),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 10,),
          AppText(
            text: title,
            fontSize: 12,
            color: AppColors.lightGrey,
          ),
          Spacer(),
          AppText(
            text: value,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),

        ],
      ),
    );
  }

  Widget _buildMostPopularSessions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Most Popular Sessions',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 16),
          _buildSessionItem('AI in Healthcare', 'Dr. Sarah Ahmed', '324 Attendees'),
          _buildSessionItem('Sustainable Development', 'Prof. Michael Chen', '298 Attendees'),
          _buildSessionItem('Sustainable Development', 'Prof. Michael Chen', '285 Attendees'),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String title, String speaker, String attendees) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event, color: AppColors.primaryColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkgrey,
                ),
                AppText(
                  text: speaker,
                  fontSize: 12,
                  color: AppColors.lightGrey,
                ),
              ],
            ),
          ),
          AppText(
            text: attendees,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Engagement Metrics',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: AppColors.primaryColor,
                    value: 40,
                    title: 'Sessions',
                    radius: 60,
                    titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  PieChartSectionData(
                    color: AppColors.successColor,
                    value: 30,
                    title: 'Networking',
                    radius: 60,
                    titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  PieChartSectionData(
                    color: AppColors.warningColor,
                    value: 20,
                    title: 'Exhibits',
                    radius: 60,
                    titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  PieChartSectionData(
                    color: AppColors.chartColor3,
                    value: 10,
                    title: 'Other',
                    radius: 60,
                    titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Participant Demographics',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),

          // By Organization Type
          AppText(
            text: 'By Organization Type',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 12),
          _buildProgressBar('Universities', '42%', 0.42, AppColors.chartColor3),
          _buildProgressBar('Corporates', '35%', 0.35, AppColors.successColor),
          _buildProgressBar('Government', '23%', 0.23, AppColors.warningColor),

          SizedBox(height: 20),

          // By Region
          AppText(
            text: 'By Region',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 12),
          _buildRegionItem('Middle East', '456'),
          _buildRegionItem('North America', '342'),
          _buildRegionItem('Europe', '289'),
          _buildRegionItem('Asia Pacific', '160'),

          SizedBox(height: 20),

          // Experience Level
          AppText(
            text: 'Experience Level',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 12),
          _buildProgressBar('Senior (7-10 years)', '38%', 0.38, AppColors.primaryColor),
          _buildProgressBar('Mid-level (3-7 years)', '35%', 0.35, AppColors.chartColor5),
          _buildProgressBar('Junior (0-3 years)', '27%', 0.27, AppColors.chartColor6),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String percentage, double progress, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              text: label,
              fontSize: 12,
              color: AppColors.darkgrey,
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: 8),
          AppText(
            text: percentage,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildRegionItem(String region, String count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: region,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          AppText(
            text: count,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentParticipants() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Recent Participants',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 16),
          _buildParticipantItem('Ahmed Al-Rashid', 'Prof, Goldman Ins', 'https://i.pravatar.cc/150?img=1'),
          _buildParticipantItem('Sarah Mitchell', 'Environment Lead', 'https://i.pravatar.cc/150?img=2'),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(String name, String title, String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkgrey,
                ),
                AppText(
                  text: title,
                  fontSize: 12,
                  color: AppColors.lightGrey,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: AppText(
              text: 'View Details',
              fontSize: 12,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    Get.snackbar('Success', 'Report exported successfully!',
        backgroundColor: AppColors.successColor.withOpacity(0.1),
        colorText: AppColors.successColor);
  }
}