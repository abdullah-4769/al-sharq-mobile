import 'package:al_sharq_conference/view/home_page/live_chat_session_view/session_content.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/view/home_page/live_chat_session_view/video_player_widget.dart';
import '../../../app_colors/app_colors.dart';
import '../../../custom_widgets/app_text.dart';

class LiveSessionScreen extends StatefulWidget {
  final String name;
  final bool isHost;
  final String time;
  final String message;
  final int likes;

  const LiveSessionScreen({
    Key? key,
    this.name = "The Future of Regional Cooperation",
    this.isHost = false,
    this.time = "11:59 AM PKT",
    this.message = "Dr. Johnathan • Director of Regional Affairs",
    this.likes = 0,
  }) : super(key: key);

  @override
  _LiveSessionScreenState createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            AppText(
              text: "Live Session",
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            AppText(text: "Now Live • 234 participants"),
          ],
        ),
      ),
      backgroundColor: AppColors.lightGreyColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 768;

          if (isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: VideoPlayerWidget(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 200),
                        child: SingleChildScrollView(
                          child: SessionContentWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 350,
                  child: SingleChildScrollView(
                    child: SessionContentWidget(),
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: VideoPlayerWidget(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: SingleChildScrollView(
                    child: SessionContentWidget(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}