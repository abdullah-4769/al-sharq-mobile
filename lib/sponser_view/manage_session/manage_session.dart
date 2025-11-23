import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_drawer.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_dashboard_data_get_model.dart';
import '../../images/images.dart';
import '../../participants_view/seesion_details_view/session_detail_view.dart';
import '../../view_model/sponsor_viewmodel/sponsor_dashboard_data_get_viewmodel.dart';
import '../../view_model/sponsor_viewmodel/sponsor_profile_get_viewmodel.dart';
import '../sponsor_profile_screen.dart';

class SponserDashboardScreen extends StatefulWidget {
  const SponserDashboardScreen({super.key});

  @override
  _SponserDashboardScreenState createState() => _SponserDashboardScreenState();
}

class _SponserDashboardScreenState extends State<SponserDashboardScreen> {
  final SponsorDashboardDataViewModel viewModel = Get.put(SponsorDashboardDataViewModel());
  final SponsorProfileGetViewModel profileViewModel = Get.put(SponsorProfileGetViewModel());
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load both dashboard data and profile data
    viewModel.fetchSponsorDashboardData();
    profileViewModel.fetchSponsorProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.refreshData();
      profileViewModel.refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      drawer: const CustomAppDrawer(),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.refreshData();
           profileViewModel.refreshProfile();
        },
        child: Obx(() {
          if (viewModel.isLoadingData) {
            return _buildLoadingState();
          } else if (viewModel.hasError) {
            return _buildErrorState();
          } else if (viewModel.hasNoData) {
            return _buildEmptyState();
          } else if (viewModel.hasData) {
            return _buildContent();
          } else {
            return _buildLoadingState();
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          AppText(
            text: 'Loading sponsor data...',
            fontSize: 16,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
            SizedBox(height: 16),
            AppText(
              text: 'Failed to load data',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 8),
            AppText(
              text: viewModel.errorMessage.value.isNotEmpty
                  ? viewModel.errorMessage.value
                  : 'An unknown error occurred',
              fontSize: 14,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: () => viewModel.refreshData(),
              backgroundColor: AppColors.primaryColor,
              height: 40,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.mediumGreyColor),
            SizedBox(height: 16),
            AppText(
              text: 'No sessions found',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 8),
            AppText(
              text: 'There are no sessions available for your sponsor account.',
              fontSize: 14,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Refresh',
              onPressed: () => viewModel.refreshData(),
              backgroundColor: AppColors.primaryColor,
              height: 40,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildStatsCards(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildSessionsList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: AppColors.blackColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
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
            onPressed: () {
              Get.to(ChatListScreen());
            },
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
        // Profile Avatar with real image
        Obx(() {
          final profile = profileViewModel.sponsorProfile.value?.data;
          return GestureDetector(
            onTap: () {
              Get.to(() => SponsorProfileScreen());
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.mediumGreyColor,
              backgroundImage: profile?.picUrl.isNotEmpty == true
                  ? NetworkImage(profile!.picUrl)
                  : AssetImage(Images.drjohnthan) as ImageProvider,
              child: profile?.picUrl.isEmpty == true
                  ? Icon(Icons.person, color: AppColors.whiteColor)
                  : null,
            ),
          );
        }),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.whiteColor,
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
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
        onChanged: (value) {
          // Implement search functionality if needed
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Sessions', '${viewModel.totalSessions}', Icons.event)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Live Sessions', '${viewModel.ongoingSessions}', Icons.play_circle_filled, color: AppColors.successColor)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Scheduled Sessions', '${viewModel.scheduledSessions}', Icons.schedule, color: AppColors.warningColor)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, {Color? color}) {
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
            child: Icon(
              icon,
              color: color ?? AppColors.lightBlue,
              size: 20,
            ),
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
    final sessionsByDate = viewModel.sessionsByDate;

    if (sessionsByDate.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: AppText(
          text: 'No sessions available for the selected dates.',
          fontSize: 14,
          color: AppColors.darkgrey,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: sessionsByDate.entries.map((entry) {
        return Column(
          children: [
            _buildDateHeader(viewModel.getFormattedDate(entry.key)),
            ...entry.value.map((session) => _buildSessionCard(session)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: date,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          AppText(
            text: '${viewModel.sessionsByDate.entries.firstWhere((element) => viewModel.getFormattedDate(element.key) == date).value.length} Sessions',
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SponsorSession session) {
    final statusColor = session.isLive ? AppColors.successColor :
    session.isCompleted ? AppColors.darkgrey :
    AppColors.warningColor;

    final typeColor = session.category == 'Workshop' ? AppColors.lightBlue :
    session.category == 'Keynote' ? AppColors.primaryColor :
    AppColors.warningColor;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: session.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: session.sessionStatus,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          if (session.speakers.isNotEmpty) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage: session.speakers.first.file.isNotEmpty
                      ? NetworkImage(session.speakers.first.file)
                      : null,
                  child: session.speakers.first.file.isEmpty
                      ? AppText(
                    text: session.speakers.first.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(''),
                    fontSize: 10,
                    color: AppColors.whiteColor,
                  )
                      : null,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: session.speakers.first.name,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppText(
                        text: 'Speaker',
                        fontSize: 12,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],

          if (session.description.isNotEmpty) ...[
            AppText(
              text: session.description,
              fontSize: 13,
              color: AppColors.darkgrey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
          ],

          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: session.timeRange,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: session.category,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: typeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            children: [
              AppText(
                text: 'Duration',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              Spacer(),
              AppText(
                text: session.duration,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              AppText(
                text: 'Location',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              Spacer(),
              AppText(
                text: session.location,
                fontSize: 12,
                color: AppColors.darkgrey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 16),

          CustomButton(
            text: 'View Details',
            onPressed: () {
              _handleSessionAction(session);
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _handleSessionAction(SponsorSession session) {
    Get.to(() => SessionDetailsScreen(
      sessionId: session.id,
      key: ValueKey('session_${session.id}'),
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}