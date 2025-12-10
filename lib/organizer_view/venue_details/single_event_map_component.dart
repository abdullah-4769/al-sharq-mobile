// // lib/organizer_view/event_details/single_event_map_component.dart
//
// import 'package:flutter/material.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
//
// class SingleEventMapComponent extends StatelessWidget {
//   final String eventName;
//   final String googleMapLink;
//   final String location;
//
//   const SingleEventMapComponent({
//     Key? key,
//     required this.eventName,
//     required this.googleMapLink,
//     required this.location,
//   }) : super(key: key);
//
//   (double, double)? _extractCoordinates() {
//     try {
//       final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
//       final match = regex.firstMatch(googleMapLink);
//       if (match != null) {
//         final lat = double.parse(match.group(1)!);
//         final lng = double.parse(match.group(2)!);
//         return (lat, lng);
//       }
//     } catch (e) {
//       print('Error extracting coordinates: $e');
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final coordinates = _extractCoordinates();
//     final hasValidMap = coordinates != null;
//
//     return Container(
//       height: 250,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             // Map Preview
//             Container(
//               color: Colors.blue.shade50,
//               child: hasValidMap
//                   ? _buildMapPreview()
//                   : _buildNoMapPlaceholder(),
//             ),
//
//             // Location Pin
//             if (hasValidMap)
//               Positioned(
//                 top: MediaQuery.of(context).size.height * 0.1,
//                 left: MediaQuery.of(context).size.width * 0.45,
//                 child: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.location_on,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//
//             // Location Info Card
//             Positioned(
//               bottom: 10,
//               left: 10,
//               right: 10,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.95),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               AppText(
//                                 text: eventName,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                               SizedBox(height: 4),
//                               AppText(
//                                 text: location,
//                                 fontSize: 12,
//                                 color: AppColors.darkgrey,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                             ],
//                           ),
//                         ),
//                         if (hasValidMap)
//                           GestureDetector(
//                             onTap: () {
//                               // Launch Google Maps
//                               // _launchUrl(googleMapLink);
//                             },
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryColor,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.directions,
//                                     size: 16,
//                                     color: Colors.white,
//                                   ),
//                                   SizedBox(width: 6),
//                                   AppText(
//                                     text: 'Directions',
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     if (hasValidMap)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.gps_fixed,
//                               size: 14,
//                               color: Colors.green,
//                             ),
//                             SizedBox(width: 4),
//                             Expanded(
//                               child: AppText(
//                                 text: 'Coordinates: ${coordinates!.$1.toStringAsFixed(6)}, ${coordinates.$2.toStringAsFixed(6)}',
//                                 fontSize: 11,
//                                 color: AppColors.darkgrey,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMapPreview() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.blue.shade100,
//             Colors.blue.shade50,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.map,
//             size: 48,
//             color: AppColors.primaryColor,
//           ),
//           SizedBox(height: 12),
//           AppText(
//             text: 'Event Location',
//             fontSize: 16,
//             color: AppColors.primaryColor,
//             fontWeight: FontWeight.w600,
//           ),
//           SizedBox(height: 4),
//           AppText(
//             text: 'Tap for directions',
//             fontSize: 12,
//             color: AppColors.darkgrey,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoMapPlaceholder() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.location_off,
//             size: 48,
//             color: Colors.grey.shade400,
//           ),
//           SizedBox(height: 12),
//           AppText(
//             text: 'Location Not Mapped',
//             fontSize: 16,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//           SizedBox(height: 4),
//           AppText(
//             text: location,
//             fontSize: 12,
//             color: Colors.grey.shade500,
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }