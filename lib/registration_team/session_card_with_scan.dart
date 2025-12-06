




// lib/participants_view/registration_team/session_card_with_scan.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/data/response_models/participant_response_model/session_model.dart';
import 'package:al_sharq_conference/qr_code/universal_qr_code_scan.dart';

import 'event_registration_scan_screen.dart';

class SessionCardWithScan extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onViewDetails;
  final bool showScanButton;

  const SessionCardWithScan({
    super.key,
    required this.session,
    required this.onViewDetails,
    this.showScanButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getSessionStatus(session);
    final tagColor = _getTagColor(session.category ?? 'Session');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: session.isCurrentlyLive ? Colors.red.shade300 :
          session.isPast ? Colors.grey.shade300 : Colors.grey.shade200,
          width: session.isCurrentlyLive ? 2 : 1,
        ),
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
          // Status Badge and Scan Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(status),
              if (showScanButton) _buildScanButton(context),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          AppText(
            text: session.sessionTitle,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Time and Date
          Row(
            children: [
              Icon(
                session.isToday ? Icons.access_time : Icons.calendar_today,
                size: 16,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: session.formattedTime,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(
                      text: _getFormattedDate(session),
                      fontSize: 12,
                      color: AppColors.darkgrey.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  session.category ?? 'Session',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Speakers
          if (session.speakers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: "Speakers",
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: session.speakers.map((speaker) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (speaker.pic != null)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(speaker.pic!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            speaker.fullName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Location and Duration
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.darkgrey),
                  const SizedBox(width: 4),
                  Text(
                    session.location ?? 'Online',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 14, color: AppColors.darkgrey),
                  const SizedBox(width: 4),
                  Text(
                    session.durationInMinutes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: session.isPast ? Colors.grey : AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status['color'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status['icon'],
            size: 12,
            color: status['color'],
          ),
          const SizedBox(width: 6),
          Text(
            status['text'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => UniversalQRScannerScreen(
                          sessionId: session.sessionId,
                          sessionTitle: session.sessionTitle,
                          sessionTime: session.formattedTime,
                          showGalleryOption: true,
                        ));

        // // Show options for scanning
        // showModalBottomSheet(
        //   context: context,
        //   shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        //   ),
        //   builder: (context) {
        //     return Container(
        //       padding: const EdgeInsets.all(20),
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           const Text(
        //             'Check Registration',
        //             style: TextStyle(
        //               fontSize: 18,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           // const SizedBox(height: 10),
        //           // const Text(
        //           //   'Choose how to check registration for this session',
        //           //   style: TextStyle(color: Colors.grey),
        //           //   textAlign: TextAlign.center,
        //           // ),
        //           // const SizedBox(height: 20),
        //           // ListTile(
        //           //   leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
        //           //   title: const Text('Scan QR Code'),
        //           //   subtitle: const Text('Scan participant QR to check'),
        //           //   onTap: () {
        //           //     Navigator.pop(context);
        //           //     Get.to(() => UniversalQRScannerScreen(
        //           //       sessionId: session.sessionId,
        //           //       sessionTitle: session.sessionTitle,
        //           //       sessionTime: session.formattedTime,
        //           //       showGalleryOption: true,
        //           //     ));
        //           //   },
        //           // ),
        //           // ListTile(
        //           //   leading: const Icon(Icons.event, color: Colors.green),
        //           //   title: const Text('Event Registration Check'),
        //           //   subtitle: const Text('Check overall event registration'),
        //           //   onTap: () {
        //           //     Navigator.pop(context);
        //           //     Get.to(() => EventRegistrationScanScreen(
        //           //       eventId: session.sessionId.toString(),
        //           //     ));
        //           //   },
        //           // ),
        //           // const SizedBox(height: 20),
        //           // OutlinedButton(
        //           //   onPressed: () => Navigator.pop(context),
        //           //   style: OutlinedButton.styleFrom(
        //           //     minimumSize: const Size(double.infinity, 50),
        //           //   ),
        //           //   child: const Text('Cancel'),
        //           // ),
        //         ],
        //       ),
        //     );
        //   },
        // );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Check Registration',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getSessionStatus(SessionModel session) {
    if (session.isCurrentlyLive) {
      return {
        'text': 'Live Now',
        'color': Colors.red,
        'icon': Icons.live_tv,
        'backgroundColor': Colors.red.withOpacity(0.1),
      };
    } else if (session.isUpcomingToday) {
      final minutes = session.minutesUntilStart;
      String text = 'Upcoming Today';
      if (minutes != null && minutes > 0) {
        if (minutes > 60) {
          text = 'Starts in ${minutes ~/ 60}h ${minutes % 60}m';
        } else {
          text = 'Starts in ${minutes}m';
        }
      }
      return {
        'text': text,
        'color': Colors.blue,
        'icon': Icons.access_time,
        'backgroundColor': Colors.blue.withOpacity(0.1),
      };
    } else if (session.isUpcoming) {
      return {
        'text': 'Upcoming',
        'color': Colors.green,
        'icon': Icons.upcoming,
        'backgroundColor': Colors.green.withOpacity(0.1),
      };
    } else if (session.isPast) {
      return {
        'text': 'Completed',
        'color': Colors.grey,
        'icon': Icons.check_circle,
        'backgroundColor': Colors.grey.withOpacity(0.1),
      };
    } else {
      return {
        'text': 'Scheduled',
        'color': AppColors.primaryColor,
        'icon': Icons.calendar_today,
        'backgroundColor': AppColors.primaryColor.withOpacity(0.1),
      };
    }
  }

  Color _getTagColor(String sessionType) {
    final type = sessionType.toLowerCase();
    if (type.contains('keynote')) {
      return AppColors.darkBlue;
    } else if (type.contains('panel')) {
      return Colors.yellow[700]!;
    } else if (type.contains('workshop')) {
      return Colors.green;
    } else if (type.contains('breakout')) {
      return Colors.orange;
    } else if (type.contains('networking')) {
      return Colors.purple;
    } else if (type.contains('general discussion')) {
      return Colors.blue;
    } else {
      return AppColors.primaryColor;
    }
  }

  String _getFormattedDate(SessionModel session) {
    final startDate = session.startDateTime;
    final now = DateTime.now();

    if (session.isToday) {
      return 'Today';
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(startDate);
  }
}





// // lib/participants_view/registration_team/session_card_with_scan.dart
// import 'package:al_sharq_conference/registration_team/registration_team_session_scanner.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:al_sharq_conference/data/response_models/participant_response_model/session_model.dart';
// import 'package:al_sharq_conference/qr_code/registration_team_scanner_screen.dart';
//
// import '../qr_code/universal_qr_code_scan.dart';
//
// class SessionCardWithScan extends StatelessWidget {
//   final SessionModel session;
//   final VoidCallback onViewDetails;
//   final bool showScanButton;
//
//   const SessionCardWithScan({
//     super.key,
//     required this.session,
//     required this.onViewDetails,
//     this.showScanButton = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final status = _getSessionStatus(session);
//     final tagColor = _getTagColor(session.category ?? 'Session');
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: session.isCurrentlyLive ? Colors.red.shade300 :
//           session.isPast ? Colors.grey.shade300 : Colors.grey.shade200,
//           width: session.isCurrentlyLive ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Status Badge and Scan Button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStatusBadge(status),
//               if (showScanButton) _buildScanButton(),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // Title
//           AppText(
//             text: session.sessionTitle,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 8),
//
//           // Time and Date
//           Row(
//             children: [
//               Icon(
//                 session.isToday ? Icons.access_time : Icons.calendar_today,
//                 size: 16,
//                 color: AppColors.darkgrey,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       text: session.formattedTime,
//                       fontSize: 14,
//                       color: AppColors.darkgrey,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     AppText(
//                       text: _getFormattedDate(session),
//                       fontSize: 12,
//                       color: AppColors.darkgrey.withOpacity(0.7),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: tagColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Text(
//                   session.category ?? 'Session',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: tagColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // Speakers
//           if (session.speakers.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: "Speakers",
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 4,
//                   children: session.speakers.map((speaker) {
//                     return Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (speaker.pic != null)
//                             Container(
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                   image: NetworkImage(speaker.pic!),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           else
//                             Container(
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey.shade300,
//                               ),
//                               child: Icon(
//                                 Icons.person,
//                                 size: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           const SizedBox(width: 6),
//                           Text(
//                             speaker.fullName,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//
//           // Location and Duration
//           Wrap(
//             spacing: 16,
//             runSpacing: 8,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.location_on, size: 14, color: AppColors.darkgrey),
//                   const SizedBox(width: 4),
//                   Text(
//                     session.location ?? 'Online',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.darkgrey,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.timer, size: 14, color: AppColors.darkgrey),
//                   const SizedBox(width: 4),
//                   Text(
//                     session.durationInMinutes,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.darkgrey,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // View Details Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: onViewDetails,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: session.isPast ? Colors.grey : AppColors.primaryColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: const Text(
//                 "View Details",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(Map<String, dynamic> status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: status['backgroundColor'],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: status['color'].withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             status['icon'],
//             size: 12,
//             color: status['color'],
//           ),
//           const SizedBox(width: 6),
//           Text(
//             status['text'],
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: status['color'],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// // Update in SessionCardWithScan.dart
//   Widget _buildScanButton() {
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => UniversalQRScannerScreen(
//           sessionId: session.sessionId,
//           sessionTitle: session.sessionTitle,
//           sessionTime: session.formattedTime,
//           showGalleryOption: true,
//         ));
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.green.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.green),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.qr_code_scanner, size: 14, color: Colors.green),
//             const SizedBox(width: 4),
//             Text(
//               'Check Registration',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Map<String, dynamic> _getSessionStatus(SessionModel session) {
//     if (session.isCurrentlyLive) {
//       return {
//         'text': 'Live Now',
//         'color': Colors.red,
//         'icon': Icons.live_tv,
//         'backgroundColor': Colors.red.withOpacity(0.1),
//       };
//     } else if (session.isUpcomingToday) {
//       final minutes = session.minutesUntilStart;
//       String text = 'Upcoming Today';
//       if (minutes != null && minutes > 0) {
//         if (minutes > 60) {
//           text = 'Starts in ${minutes ~/ 60}h ${minutes % 60}m';
//         } else {
//           text = 'Starts in ${minutes}m';
//         }
//       }
//       return {
//         'text': text,
//         'color': Colors.blue,
//         'icon': Icons.access_time,
//         'backgroundColor': Colors.blue.withOpacity(0.1),
//       };
//     } else if (session.isUpcoming) {
//       return {
//         'text': 'Upcoming',
//         'color': Colors.green,
//         'icon': Icons.upcoming,
//         'backgroundColor': Colors.green.withOpacity(0.1),
//       };
//     } else if (session.isPast) {
//       return {
//         'text': 'Completed',
//         'color': Colors.grey,
//         'icon': Icons.check_circle,
//         'backgroundColor': Colors.grey.withOpacity(0.1),
//       };
//     } else {
//       return {
//         'text': 'Scheduled',
//         'color': AppColors.primaryColor,
//         'icon': Icons.calendar_today,
//         'backgroundColor': AppColors.primaryColor.withOpacity(0.1),
//       };
//     }
//   }
//
//   Color _getTagColor(String sessionType) {
//     final type = sessionType.toLowerCase();
//     if (type.contains('keynote')) {
//       return AppColors.darkBlue;
//     } else if (type.contains('panel')) {
//       return Colors.yellow[700]!;
//     } else if (type.contains('workshop')) {
//       return Colors.green;
//     } else if (type.contains('breakout')) {
//       return Colors.orange;
//     } else if (type.contains('networking')) {
//       return Colors.purple;
//     } else if (type.contains('general discussion')) {
//       return Colors.blue;
//     } else {
//       return AppColors.primaryColor;
//     }
//   }
//
//   String _getFormattedDate(SessionModel session) {
//     final startDate = session.startDateTime;
//     final now = DateTime.now();
//
//     if (session.isToday) {
//       return 'Today';
//     }
//
//     final dateFormat = DateFormat('MMM dd, yyyy');
//     return dateFormat.format(startDate);
//   }
// }