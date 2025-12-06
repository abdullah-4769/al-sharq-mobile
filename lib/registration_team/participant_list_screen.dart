// lib/participants_view/participant_list/participant_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/data/response_models/registration_team_model/participant_response_model.dart';
import 'package:al_sharq_conference/view_model/registration_team_viewmodels/participant_list_viewmodel.dart';
import 'package:al_sharq_conference/qr_code/registration_team_scanner_screen.dart';
import 'package:al_sharq_conference/qr_code/gallery_qr_scanner_service.dart';
import 'package:al_sharq_conference/qr_code/participant_qr_dialog.dart';
import 'package:al_sharq_conference/registration_team/participant_detail_by_id_screen.dart';

import '../participants_view/all_sessions_screen.dart';
import '../qr_code/multi_purpose_scanner_screen.dart';
import '../qr_code/qr_generator_service.dart';
import '../qr_code/universal_qr_code_scan.dart';
import '../utils/shared_preference.dart';
import '../view_model/registration_team_viewmodels/event_registration_viewmodel.dart';
import 'event_registration_scan_screen.dart';


class ParticipantListScreen extends StatefulWidget {
  const ParticipantListScreen({super.key});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final ParticipantListViewModel _viewModel = ParticipantListViewModel();
  final EventRegistrationViewModel _registrationViewModel = Get.put(EventRegistrationViewModel());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _showLimitedView = true.obs;
  final int _maxVisibleParticipants = 4;
  final RxInt _totalEventRegistrations = 0.obs;
  final RxInt _totalEventNotRegistered = 0.obs;
  final RxBool _isEventRegistrationRequired = false.obs;
  final RxString _currentEventId = ''.obs;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchParticipants();
    _loadEventIdAndCheckRegistration();

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_viewModel.isLoading.value && _viewModel.hasMore.value) {
          _viewModel.loadMoreParticipants();
        }
      }
    });

    // Setup search listener
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _viewModel.searchQuery.value = '';
        _viewModel.fetchParticipants();
      }
    });
  }

  Future<void> _loadEventIdAndCheckRegistration() async {
    try {
      // Get event ID from SharedPreferences
      final eventId = await SharedPrefsHelper.getLatestEventId();
      if (eventId != null) {
        _currentEventId.value = eventId.toString();

        // You could pre-load registration stats here if needed
        // For now, we'll just store the event ID
        print('Loaded event ID from SharedPreferences: $eventId');
      } else {
        print('No event ID found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading event ID: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  List<Participant> get _displayParticipants {
    if (_showLimitedView.value) {
      return _viewModel.filteredParticipants.take(_maxVisibleParticipants).toList();
    }
    return _viewModel.filteredParticipants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Participants List',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        // actions: [
        //   // Check Sessions Button
        //   IconButton(
        //     icon: const Icon(Icons.event, color: Colors.black),
        //     onPressed: () {
        //       Get.to(() => const AllSessionsScreen());
        //     },
        //     tooltip: 'Check Sessions',
        //   ),
        //   // Scan QR Code Button
        //   IconButton(
        //     icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
        //     onPressed: _showScanOptions,
        //     tooltip: 'Scan QR Code',
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),

          // Stats Cards - UPDATED WITH EVENT REGISTRATION
          _buildStatsSection(),

          // Filter Chips
          _buildFilterChips(),

          // View Toggle Button
          _buildViewToggle(),

          // Participants List - Dynamic Container
          _buildParticipantsContainer(),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _showScanOptions,
      //   icon: const Icon(Icons.qr_code_scanner),
      //   label: const AppText(
      //     text: 'Scan QR',
      //     fontSize: 14,
      //     color: Colors.white,
      //   ),
      //   backgroundColor: AppColors.primaryColor,
      // ),
    );
  }

  Widget _buildSearchFilterSection() {
    Timer? _debounce;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, email, or organization...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (value.isNotEmpty) {
                          _viewModel.searchQuery.value = value;
                          _viewModel.searchParticipants();
                        } else {
                          _viewModel.searchQuery.value = '';
                          _viewModel.fetchParticipants();
                        }
                      });
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _viewModel.searchQuery.value = '';
                      _viewModel.fetchParticipants();
                    },
                  ),
              ],
            ),
          ),

          // // Event ID Display
          // Obx(() {
          //   if (_currentEventId.value.isNotEmpty) {
          //     return Padding(
          //       padding: const EdgeInsets.only(top: 8),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Icon(Icons.event, size: 14, color: Colors.blue),
          //           const SizedBox(width: 4),
          //           AppText(
          //             text: 'Event ID: ${_currentEventId.value}',
          //             fontSize: 12,
          //             color: Colors.blue,
          //             fontWeight: FontWeight.w500,
          //           ),
          //           const SizedBox(width: 8),
          //           GestureDetector(
          //             onTap: _showEventIdOptions,
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //               decoration: BoxDecoration(
          //                 color: Colors.blue.withOpacity(0.1),
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               child: const Icon(Icons.edit, size: 12, color: Colors.blue),
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }
          //   return const SizedBox();
          // }),
        ],
      ),
    );
  }
  //
  // void _showEventIdOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const SizedBox(height: 10),
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[300],
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             const Text(
  //               'Event Settings',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             const Text(
  //               'Manage event ID and registration settings',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //             const SizedBox(height: 20),
  //
  //             // Current Event ID
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.blue.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Row(
  //                 children: [
  //                   const Icon(Icons.event, color: Colors.blue),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         const Text(
  //                           'Current Event ID',
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                         Obx(() => Text(
  //                           _currentEventId.value.isNotEmpty ? _currentEventId.value : 'Not set',
  //                           style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black,
  //                           ),
  //                         )),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             const SizedBox(height: 16),
  //
  //             // Change Event ID
  //             ListTile(
  //               leading: const Icon(Icons.edit, color: Colors.blue),
  //               title: const Text('Change Event ID'),
  //               subtitle: const Text('Set a different event ID'),
  //               onTap: () {
  //                 Get.back();
  //                 _changeEventId();
  //               },
  //             ),
  //
  //             // Check Event Registration
  //             ListTile(
  //               leading: const Icon(Icons.verified_user, color: Colors.green),
  //               title: const Text('Check Event Registration'),
  //               subtitle: const Text('Scan to check event registration'),
  //               onTap: () {
  //                 Get.back();
  //                 _checkEventRegistration();
  //               },
  //             ),
  //
  //             // Refresh Event Data
  //             ListTile(
  //               leading: const Icon(Icons.refresh, color: Colors.orange),
  //               title: const Text('Refresh Event Data'),
  //               subtitle: const Text('Reload event information'),
  //               onTap: () {
  //                 Get.back();
  //                 _loadEventIdAndCheckRegistration();
  //                 Get.snackbar(
  //                   'Refreshed',
  //                   'Event data reloaded',
  //                   backgroundColor: Colors.green,
  //                 );
  //               },
  //             ),
  //
  //             const SizedBox(height: 20),
  //             OutlinedButton(
  //               onPressed: () => Get.back(),
  //               style: OutlinedButton.styleFrom(
  //                 minimumSize: const Size(double.infinity, 50),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 side: BorderSide(color: Colors.grey[300]!),
  //               ),
  //               child: const Text('Close'),
  //             ),
  //             const SizedBox(height: 10),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _changeEventId() {
    final TextEditingController eventIdController = TextEditingController(
      text: _currentEventId.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Change Event ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the new Event ID:'),
            const SizedBox(height: 16),
            TextField(
              controller: eventIdController,
              decoration: const InputDecoration(
                labelText: 'Event ID',
                border: OutlineInputBorder(),
                hintText: 'Enter event ID (e.g., 1)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: This will be used for all event registration checks',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEventId = eventIdController.text.trim();
              if (newEventId.isNotEmpty) {
                try {
                  final eventId = int.tryParse(newEventId);
                  if (eventId != null) {
                    await SharedPrefsHelper.saveLatestEventId(eventId.toString());
                    _currentEventId.value = newEventId;
                    Get.back();
                    Get.snackbar(
                      'Success',
                      'Event ID updated to $newEventId',
                      backgroundColor: Colors.green,
                    );

                    // Reset registration stats when event changes
                    _totalEventRegistrations.value = 0;
                    _totalEventNotRegistered.value = 0;
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid number',
                      backgroundColor: Colors.red,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to save event ID: $e',
                    backgroundColor: Colors.red,
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _viewModel.totalParticipants.value.toString(),
                    Icons.people,
                    AppColors.primaryColor,
                    onTap: () {
                      // Already shows participants list
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Bookmarks',
                    _viewModel.totalBookmarks.value.toString(),
                    Icons.bookmark,
                    Colors.amber,
                    onTap: () {
                      // Already shows bookmarks
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Registered',
                    _viewModel.totalSessionRegistrations.value.toString(),
                    Icons.event_note,
                    Colors.green,
                    onTap: () {
                      // Already shows registered
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // New Scan Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildScanCard(
                    'Scan For Profile',
                    Icons.person_search,
                    Colors.blue,
                    onTap: () => _scanForProfile(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildScanCard(
                    'Event Registration',
                    Icons.event_available,
                    Colors.purple,
                    onTap: () => _scanForEventRegistration(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildScanCard(
                    'Session Registration',
                    Icons.calendar_today,
                    Colors.orange,
                    onTap: () {
                      Get.to(() => const AllSessionsScreen());
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              text: value,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 4),
            AppText(
              text: title,
              fontSize: 11,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(String title, IconData icon, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              text: title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: AppText(
                text: 'Scan',
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _scanForSessionRegistration() {
    Get.to(() => const UniversalQRScannerScreen(
      showGalleryOption: true,
    ));
  }

  void _checkEventRegistration() {
    if (_currentEventId.value.isEmpty) {
      Get.snackbar(
        'Event ID Required',
        'Please set an Event ID first',
        backgroundColor: Colors.orange,
      );
      _changeEventId();
      return;
    }

    Get.to(() => EventRegistrationScanScreen(
      eventId: _currentEventId.value,
    ));
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          return Row(
            children: [
              _buildFilterChip('Daily', 0, _viewModel.selectedFilter.value == 0),
              const SizedBox(width: 8),
              _buildFilterChip('Weekly', 1, _viewModel.selectedFilter.value == 1),
              const SizedBox(width: 8),
              _buildFilterChip('10 Days', 2, _viewModel.selectedFilter.value == 2),
              const SizedBox(width: 8),
              _buildFilterChip('90 Days', 3, _viewModel.selectedFilter.value == 3),
              const SizedBox(width: 8),
              _buildFilterChip('All Time', 4, _viewModel.selectedFilter.value == 4),
            ],
          );
        }),
      ),
    );
  }
// Update the scan methods in ParticipantListScreen
  Future<void> _scanForProfile() async {
    Get.to(() => MultiPurposeScannerScreen(
      scanMode: ScanMode.profile,
    ));
  }

  Future<void> _scanForEventRegistration() async {
    try {
      // Get event ID from SharedPreferences
      final eventId = await SharedPrefsHelper.getLatestEventId();

      Get.to(() => MultiPurposeScannerScreen(
        scanMode: ScanMode.eventRegistration,
        eventId: eventId?.toString(),
      ));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get event ID: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // If no event ID, still open scanner but it will prompt for event ID
      Get.to(() => MultiPurposeScannerScreen(
        scanMode: ScanMode.eventRegistration,
      ));
    }
  }
  //
  // Future<void> _scanForSessionRegistration() async {
  //   // Show session selection dialog
  //   _showSessionSelectionDialog();
  // }

  void _showSessionSelectionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Session Registration Check'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you like to check session registration?'),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text('Select from Sessions'),
              subtitle: const Text('Choose a session from the list'),
              onTap: () {
                Get.back();
                Get.to(() => const AllSessionsScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
              title: const Text('Scan First, Then Select'),
              subtitle: const Text('Scan QR first, then choose session'),
              onTap: () {
                Get.back();
                Get.to(() => MultiPurposeScannerScreen(
                  scanMode: ScanMode.sessionRegistration,
                ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterChip(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _viewModel.selectedFilter.value = index;
        _viewModel.applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: AppText(
          text: label,
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Obx(() {
      if (_viewModel.filteredParticipants.length <= _maxVisibleParticipants) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              _showLimitedView.value = !_showLimitedView.value;
              // When toggling to "Show All", ensure we have enough data
              if (!_showLimitedView.value && _viewModel.filteredParticipants.length < 20) {
                _viewModel.loadMoreParticipants();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showLimitedView.value ? Icons.expand_more : Icons.expand_less,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    text: _showLimitedView.value ? 'Show All' : 'Show Less',
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildParticipantsContainer() {
    return Expanded(
      child: Obx(() {
        if (_viewModel.isLoading.value && _viewModel.filteredParticipants.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (_viewModel.filteredParticipants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const AppText(
                  text: 'No participants found',
                  fontSize: 16,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                if (_searchController.text.isNotEmpty || _viewModel.selectedFilter.value != 4)
                  ElevatedButton(
                    onPressed: () {
                      _searchController.clear();
                      _viewModel.selectedFilter.value = 4;
                      _viewModel.fetchParticipants();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const AppText(
                      text: 'Clear Filters',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        // Get the participants to display
        final participants = _displayParticipants;

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            _viewModel.fetchParticipants();
          },
          child: Column(
            children: [
              // Event Registration Quick Action
              if (_currentEventId.value.isNotEmpty)

              // The actual list of participants
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: participants.length + (_viewModel.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == participants.length) {
                      return _viewModel.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryColor),
                        ),
                      )
                          : const SizedBox.shrink();
                    }

                    final participant = participants[index];
                    return _buildParticipantCard(participant);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildParticipantCard(Participant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildProfileAvatar(participant),
        title: AppText(
          text: participant.name,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            AppText(
              text: participant.email,
              fontSize: 12,
              color: Colors.grey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (participant.organization != null && participant.organization!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  text: participant.organization!,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            children: [
              _buildActionButton(
                Icons.qr_code,
                AppColors.primaryColor,
                    () {
                  _showQRCode(participant);
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.visibility,
                Colors.blue,
                    () {
                  Get.to(() => ParticipantDetailByIdScreen(userId: participant.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Participant participant) {
    if (participant.file != null && participant.file!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(participant.file!),
        backgroundColor: Colors.grey[200],
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you want to scan the QR code',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.camera_alt,
                      title: 'Universal Scan',
                      subtitle: 'Scan any QR code',
                      color: AppColors.primaryColor,
                      onTap: () {
                        Get.back();
                        Get.to(() => const UniversalQRScannerScreen(
                          showGalleryOption: true,
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.event,
                      title: 'Event Check',
                      subtitle: 'Check event registration',
                      color: Colors.blue,
                      onTap: () {
                        Get.back();
                        _checkEventRegistration();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.photo_library,
                      title: 'Gallery Scan',
                      subtitle: 'Scan from gallery',
                      color: Colors.green,
                      onTap: () async {
                        Get.back();
                        final data = await GalleryQRScannerService.scanQRFromGallery(context);
                        if (data != null) {
                          GalleryQRScannerService.showParticipantDetails(data);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.event_note,
                      title: 'Session Check',
                      subtitle: 'Check session registration',
                      color: Colors.purple,
                      onTap: () {
                        Get.back();
                        _scanForSessionRegistration();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(Participant participant) {
    Get.dialog(
      ParticipantQRDialog(participant: participant),
    );
  }
}













// // lib/participants_view/participant_list/participant_list_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
// import 'package:al_sharq_conference/data/response_models/registration_team_model/participant_response_model.dart';
// import 'package:al_sharq_conference/view_model/registration_team_viewmodels/participant_list_viewmodel.dart';
// import 'package:al_sharq_conference/qr_code/registration_team_scanner_screen.dart';
// import 'package:al_sharq_conference/qr_code/gallery_qr_scanner_service.dart';
// import 'package:al_sharq_conference/qr_code/participant_qr_dialog.dart';
// import 'package:al_sharq_conference/registration_team/participant_detail_by_id_screen.dart';
//
// import '../participants_view/all_sessions_screen.dart';
// import '../qr_code/qr_generator_service.dart';
//
// class ParticipantListScreen extends StatefulWidget {
//   const ParticipantListScreen({super.key});
//
//   @override
//   State<ParticipantListScreen> createState() => _ParticipantListScreenState();
// }
//
// class _ParticipantListScreenState extends State<ParticipantListScreen> {
//   final ParticipantListViewModel _viewModel = ParticipantListViewModel();
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final RxBool _showLimitedView = true.obs;
//   final int _maxVisibleParticipants = 4;
//
//   @override
//   void initState() {
//     super.initState();
//     _viewModel.fetchParticipants();
//
//     // Setup scroll listener for pagination
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//         if (!_viewModel.isLoading.value && _viewModel.hasMore.value) {
//           _viewModel.loadMoreParticipants();
//         }
//       }
//     });
//
//     // Setup search listener
//     _searchController.addListener(() {
//       if (_searchController.text.isEmpty) {
//         _viewModel.searchQuery.value = '';
//         _viewModel.fetchParticipants();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     _viewModel.dispose();
//     super.dispose();
//   }
//
// // Get participants to display based on view mode
//   List<Participant> get _displayParticipants {
//     if (_showLimitedView.value) {
//       return _viewModel.filteredParticipants.take(_maxVisibleParticipants).toList();
//     }
//     return _viewModel.filteredParticipants;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const CustomAppDrawer(),
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         elevation: 0,
//         title: const AppText(
//           text: 'Participants',
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         centerTitle: true,
//         actions: [
//           // Check Sessions Button
//           IconButton(
//             icon: const Icon(Icons.event, color: Colors.black),
//             onPressed: () {
//               Get.to(() => const AllSessionsScreen());
//             },
//             tooltip: 'Check Sessions',
//           ),
//           // Scan QR Code Button
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
//             onPressed: _showScanOptions,
//             tooltip: 'Scan QR Code',
//           ),
//
// //           // Add to your navigation
// // // In ParticipantListScreen.dart, add a test button (temporarily)
// //           IconButton(
// //             icon: const Icon(Icons.bug_report, color: Colors.black),
// //             onPressed: () {
// //               Get.to(() => const QRTestScreen());
// //             },
// //             tooltip: 'QR Test',
// //           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search and Filter Section
//           _buildSearchFilterSection(),
//
//           // Stats Cards
//           _buildStatsSection(),
//
//           // Filter Chips
//           _buildFilterChips(),
//
//           // View Toggle Button
//           _buildViewToggle(),
//
//           // Participants List - Dynamic Container
//           _buildParticipantsContainer(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showScanOptions,
//         icon: const Icon(Icons.qr_code_scanner),
//         label: const AppText(
//           text: 'Scan QR',
//           fontSize: 14,
//           color: Colors.white,
//         ),
//         backgroundColor: AppColors.primaryColor,
//       ),
//     );
//   }
//
//   Widget _buildSearchFilterSection() {
//     Timer? _debounce;
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 12),
//                 const Icon(Icons.search, color: Colors.grey, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search by name, email, or organization...',
//                       border: InputBorder.none,
//                       hintStyle: TextStyle(color: Colors.grey),
//                       contentPadding: EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     onChanged: (value) {
//                       if (_debounce?.isActive ?? false) _debounce?.cancel();
//                       _debounce = Timer(const Duration(milliseconds: 500), () {
//                         if (value.isNotEmpty) {
//                           _viewModel.searchQuery.value = value;
//                           _viewModel.searchParticipants();
//                         } else {
//                           _viewModel.searchQuery.value = '';
//                           _viewModel.fetchParticipants();
//                         }
//                       });
//                     },
//                   ),
//                 ),
//                 if (_searchController.text.isNotEmpty)
//                   IconButton(
//                     icon: const Icon(Icons.close, size: 18, color: Colors.grey),
//                     onPressed: () {
//                       _searchController.clear();
//                       _viewModel.searchQuery.value = '';
//                       _viewModel.fetchParticipants();
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatsSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Obx(() {
//         return Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 'Total',
//                 _viewModel.totalParticipants.value.toString(),
//                 Icons.people,
//                 AppColors.primaryColor,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildStatCard(
//                 'Bookmarks',
//                 _viewModel.totalBookmarks.value.toString(),
//                 Icons.bookmark,
//                 Colors.amber,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildStatCard(
//                 'Registered',
//                 _viewModel.totalSessionRegistrations.value.toString(),
//                 Icons.event_note,
//                 Colors.green,
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Icon(icon, size: 16, color: color),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           AppText(
//             text: value,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//           const SizedBox(height: 4),
//           AppText(
//             text: title,
//             fontSize: 11,
//             color: Colors.grey,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChips() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Obx(() {
//           return Row(
//             children: [
//               _buildFilterChip('Daily', 0, _viewModel.selectedFilter.value == 0),
//               const SizedBox(width: 8),
//               _buildFilterChip('Weekly', 1, _viewModel.selectedFilter.value == 1),
//               const SizedBox(width: 8),
//               _buildFilterChip('10 Days', 2, _viewModel.selectedFilter.value == 2),
//               const SizedBox(width: 8),
//               _buildFilterChip('90 Days', 3, _viewModel.selectedFilter.value == 3),
//               const SizedBox(width: 8),
//               _buildFilterChip('All Time', 4, _viewModel.selectedFilter.value == 4),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label, int index, bool isSelected) {
//     return GestureDetector(
//       onTap: () {
//         _viewModel.selectedFilter.value = index;
//         _viewModel.applyFilter();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primaryColor : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
//           ),
//         ),
//         child: AppText(
//           text: label,
//           fontSize: 12,
//           color: isSelected ? Colors.white : Colors.grey,
//           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//     );
//   }
//   Widget _buildViewToggle() {
//     return Obx(() {
//       if (_viewModel.filteredParticipants.length <= _maxVisibleParticipants) {
//         return const SizedBox();
//       }
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Align(
//           alignment: Alignment.centerRight,
//           child: GestureDetector(
//             onTap: () {
//               _showLimitedView.value = !_showLimitedView.value;
//               // When toggling to "Show All", ensure we have enough data
//               if (!_showLimitedView.value && _viewModel.filteredParticipants.length < 20) {
//                 _viewModel.loadMoreParticipants();
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     _showLimitedView.value ? Icons.expand_more : Icons.expand_less,
//                     size: 16,
//                     color: AppColors.primaryColor,
//                   ),
//                   const SizedBox(width: 4),
//                   AppText(
//                     text: _showLimitedView.value ? 'Show All' : 'Show Less',
//                     fontSize: 12,
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildParticipantsContainer() {
//     return Expanded(
//       child: Obx(() {
//         if (_viewModel.isLoading.value && _viewModel.filteredParticipants.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator(color: AppColors.primaryColor),
//           );
//         }
//
//         if (_viewModel.filteredParticipants.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
//                 const SizedBox(height: 16),
//                 const AppText(
//                   text: 'No participants found',
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//                 const SizedBox(height: 8),
//                 if (_searchController.text.isNotEmpty || _viewModel.selectedFilter.value != 4)
//                   ElevatedButton(
//                     onPressed: () {
//                       _searchController.clear();
//                       _viewModel.selectedFilter.value = 4;
//                       _viewModel.fetchParticipants();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const AppText(
//                       text: 'Clear Filters',
//                       fontSize: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//               ],
//             ),
//           );
//         }
//
//         // Get the participants to display
//         final participants = _displayParticipants;
//
//         return RefreshIndicator(
//           color: AppColors.primaryColor,
//           onRefresh: () async {
//             _viewModel.fetchParticipants();
//           },
//           child: Column(
//             children: [
//               // The actual list of participants
//               Expanded(
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   itemCount: participants.length + (_viewModel.hasMore.value ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == participants.length) {
//                       return _viewModel.isLoading.value
//                           ? const Padding(
//                         padding: EdgeInsets.all(16),
//                         child: Center(
//                           child: CircularProgressIndicator(color: AppColors.primaryColor),
//                         ),
//                       )
//                           : const SizedBox.shrink();
//                     }
//
//                     final participant = participants[index];
//                     return _buildParticipantCard(participant);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildParticipantCard(Participant participant) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: _buildProfileAvatar(participant),
//         title: AppText(
//           text: participant.name,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             AppText(
//               text: participant.email,
//               fontSize: 12,
//               color: Colors.grey,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (participant.organization != null && participant.organization!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: AppText(
//                   text: participant.organization!,
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//           ],
//         ),
//         trailing: SizedBox(
//           width: 80,
//           child: Row(
//             children: [
//               _buildActionButton(
//                 Icons.qr_code,
//                 AppColors.primaryColor,
//                     () {
//                   _showQRCode(participant);
//                 },
//               ),
//               const SizedBox(width: 8),
//               _buildActionButton(
//                 Icons.visibility,
//                 Colors.blue,
//                     () {
//                   Get.to(() => ParticipantDetailByIdScreen(userId: participant.id));
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileAvatar(Participant participant) {
//     if (participant.file != null && participant.file!.isNotEmpty) {
//       return CircleAvatar(
//         radius: 24,
//         backgroundImage: NetworkImage(participant.file!),
//         backgroundColor: Colors.grey[200],
//       );
//     }
//
//     return Container(
//       width: 48,
//       height: 48,
//       decoration: const BoxDecoration(
//         color: Colors.brown,
//         shape: BoxShape.circle,
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.person,
//           size: 24,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 18, color: color),
//       ),
//     );
//   }
//
//   void _showScanOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Scan QR Code',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Choose how you want to scan the QR code',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildScanOption(
//                       icon: Icons.camera_alt,
//                       title: 'Camera Scan',
//                       subtitle: 'Scan using camera',
//                       color: AppColors.primaryColor,
//                       onTap: () {
//                         Get.back();
//                         Get.to(() => const RegistrationTeamScannerScreen());
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: _buildScanOption(
//                       icon: Icons.photo_library,
//                       title: 'Gallery',
//                       subtitle: 'Scan from gallery',
//                       color: Colors.green,
//                       onTap: () async {
//                         Get.back();
//                         final data = await GalleryQRScannerService.scanQRFromGallery(context);
//                         if (data != null) {
//                           GalleryQRScannerService.showParticipantDetails(data);
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               OutlinedButton(
//                 onPressed: () => Get.back(),
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Widget _buildScanOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showQRCode(Participant participant) {
//     Get.dialog(
//       ParticipantQRDialog(participant: participant),
//     );
//   }
// }
//
//


