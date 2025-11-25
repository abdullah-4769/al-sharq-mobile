
import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:al_sharq_conference/participants_view/sponser_exhibitors/exhibitor_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/images/images.dart';

import '../../data/response_models/exhibitor_models/exhibitor_dashboard_model.dart';
import '../../view_model/exhibitor_view_models/exhibitor_dashboard_view_model.dart';
import '../exhibitor_venue_details/exhibitor_venue_detail.dart';
import '../session_exhibited_extension/seession_exhibitor_extension.dart';

class ExhibitorDashboardScreen extends StatefulWidget {
  final int exhibitorId; // Add this parameter

  const ExhibitorDashboardScreen({super.key, required this.exhibitorId});

  @override
  State<ExhibitorDashboardScreen> createState() => _ExhibitorDashboardScreenState();
}

class _ExhibitorDashboardScreenState extends State<ExhibitorDashboardScreen> {
  late ExhibitorSessionsViewModel _viewModel;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(ExhibitorSessionsViewModel());
    _viewModel.fetchExhibitorSessions(widget.exhibitorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_viewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (_viewModel.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: 'Error: ${_viewModel.error.value}',
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _viewModel.fetchExhibitorSessions(widget.exhibitorId),
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _viewModel.refreshSessions(widget.exhibitorId),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildExhibitorsCard(),
                _buildStatsCards(),
                _buildSessionsList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(Images.alsharqLogo)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      actions: [
        CircleAvatar(
          backgroundColor: AppColors.lightred,
          radius: 22,
          child: IconButton(
            onPressed: () => Get.to(ChatListScreen()),
            icon: Icon(Icons.chat, color: AppColors.blackColor),
          ),
        ),
        SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: AppColors.lightred,
          radius: 22,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: AppColors.blackColor),
          ),
        ),
        SizedBox(width: 10),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.mediumGreyColor,
          child: Image(image: AssetImage(Images.drjohnthan)),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.whiteColor,
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search sessions...',
          hintStyle: TextStyle(color: AppColors.darkgrey),
          prefixIcon: Icon(Icons.search, color: AppColors.darkgrey),
          suffixIcon: Icon(Icons.tune, color: AppColors.primaryColor),
          filled: true,
          fillColor: AppColors.lightGreyColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildExhibitorsCard() {
    return InkWell(
      onTap: (){
        Get.to(ExhibitorDetailScreen(id: 5, type: '',));
      },
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xffFFF9E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.store, color: AppColors.whiteColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: 'Exhibition Sessions',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Sessions',
              _viewModel.totalSessions.toString(),
              Icons.event,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Ongoing',
              _viewModel.ongoingSessions.toString(),
              Icons.play_circle_filled,
              color: AppColors.successColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Scheduled',
              _viewModel.scheduledSessions.toString(),
              Icons.schedule,
              color: AppColors.warningColor,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildStatCard(
      String title,
      String count,
      IconData icon, {
        Color? color,
      }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (color ?? AppColors.lightBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color ?? AppColors.lightBlue, size: 20),
          ),
          SizedBox(height: 12),
          AppText(
            text: count,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 4),
          AppText(
            text: title,
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return Obx(() {
      if (_viewModel.allSessions.isEmpty) {
        return Container(
          padding: EdgeInsets.all(32),
          child: const AppText(
            text: 'No sessions available',
            fontSize: 16,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        children: [
          // Today's Sessions
          if (_viewModel.todaySessions.isNotEmpty) ...[
            _buildDateHeader("Today's Sessions"),
            ..._viewModel.todaySessions
                .map((session) => _buildSessionCard(session))
                .toList(),
          ],

          // Upcoming Sessions
          if (_viewModel.upcomingSessions.isNotEmpty) ...[
            _buildDateHeader('Upcoming Sessions'),
            ..._viewModel.upcomingSessions
                .map((session) => _buildSessionCard(session))
                .toList(),
          ],

          SizedBox(height: 20),
        ],
      );
    });
  }

  Widget _buildDateHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: AppText(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _buildSessionCard(Sessions session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: "${session.title}",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Speaker info
          if (session.speakers!.isNotEmpty)
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryColor,
                  child: AppText(
                    text: session.speakers![0].name.split(' ').map((e) => e[0]).join(''),
                    fontSize: 10,
                    color: AppColors.whiteColor,
                  ),
                ),
                SizedBox(width: 8),
                AppText(
                  text: session.speakers![0].name,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ],
            ),
          SizedBox(height: 12),

          // Description
          AppText(
            text: "${session.description}",
            fontSize: 13,
            color: AppColors.darkgrey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          // Time and category
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: session.formattedTime,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _viewModel.getCategoryColor(session.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: "${session.category}",
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _viewModel.getCategoryColor(session.category),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Location and capacity
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: "${session.location}",
                fontSize: 11,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Icon(Icons.people, size: 14, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: '${session.capacity} capacity',
                fontSize: 11,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 8),

          // Duration
          Row(
            children: [
              AppText(
                text: 'Duration: ',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              AppText(
                text: session.duration,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: session.status == 'Completed'
                      ? AppColors.successColor.withOpacity(0.1)
                      : session.status == 'Ongoing'
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: session.status,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: session.status == 'Completed'
                      ? AppColors.successColor
                      : session.status == 'Ongoing'
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action button
          CustomButton(
            text: session.status == 'Completed'
                ? 'View Details'
                : session.status == 'Ongoing'
                ? 'Join Now'
                : 'Register',
            onPressed: () {

              Get.to(ExhibitorVenueDetails());
              // Action based on status
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}