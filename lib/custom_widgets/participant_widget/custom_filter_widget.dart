// lib/custom_widgets/participant_widget/custom_filter_widget.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';

class FilterOptions {
  String? day;
  String? date;
  String? title;
  String? speakerName;
  String? category;
  String? location;

  FilterOptions({
    this.day,
    this.date,
    this.title,
    this.speakerName,
    this.category,
    this.location,
  });

  FilterOptions copyWith({
    String? day,
    String? date,
    String? title,
    String? speakerName,
    String? category,
    String? location,
  }) {
    return FilterOptions(
      day: day ?? this.day,
      date: date ?? this.date,
      title: title ?? this.title,
      speakerName: speakerName ?? this.speakerName,
      category: category ?? this.category,
      location: location ?? this.location,
    );
  }

  bool get hasActiveFilters {
    return day?.isNotEmpty == true ||
        date?.isNotEmpty == true ||
        title?.isNotEmpty == true ||
        speakerName?.isNotEmpty == true ||
        category?.isNotEmpty == true ||
        location?.isNotEmpty == true;
  }

  void clear() {
    day = null;
    date = null;
    title = null;
    speakerName = null;
    category = null;
    location = null;
  }
}

class CustomFilterDialog extends StatefulWidget {
  final FilterOptions initialFilters;
  final List<String> availableDays;
  final List<String> availableDates;
  final List<String> availableCategories;
  final List<String> availableLocations;
  final List<String> availableSpeakers;
  final Function(FilterOptions) onApplyFilters;
  final Function() onClearFilters;

  const CustomFilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
    this.availableDays = const [],
    this.availableDates = const [],
    this.availableCategories = const [],
    this.availableLocations = const [],
    this.availableSpeakers = const [],
  });

  @override
  State<CustomFilterDialog> createState() => _CustomFilterDialogState();
}

class _CustomFilterDialogState extends State<CustomFilterDialog> {
  late FilterOptions _currentFilters;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters.copyWith();
    _titleController.text = _currentFilters.title ?? '';
    _speakerController.text = _currentFilters.speakerName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  text: 'Filter Sessions',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const AppText(
              text: 'Apply filters to find specific sessions',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            const SizedBox(height: 24),

            // Filter Options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Day Filter
                    if (widget.availableDays.isNotEmpty) ...[
                      _buildFilterSection(
                        title: 'Day',
                        options: widget.availableDays,
                        selectedValue: _currentFilters.day,
                        onSelected: (value) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(day: value);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Date Filter
                    if (widget.availableDates.isNotEmpty) ...[
                      _buildFilterSection(
                        title: 'Date',
                        options: widget.availableDates,
                        selectedValue: _currentFilters.date,
                        onSelected: (value) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(date: value);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Title Search
                    _buildTextFilter(
                      title: 'Session Title',
                      hintText: 'Search by session title',
                      controller: _titleController,
                      onChanged: (value) {
                        _currentFilters = _currentFilters.copyWith(title: value);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Speaker Filter
                    if (widget.availableSpeakers.isNotEmpty) ...[
                      _buildFilterSection(
                        title: 'Speaker',
                        options: widget.availableSpeakers,
                        selectedValue: _currentFilters.speakerName,
                        onSelected: (value) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(speakerName: value);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      _buildTextFilter(
                        title: 'Speaker Name',
                        hintText: 'Search by speaker name',
                        controller: _speakerController,
                        onChanged: (value) {
                          _currentFilters = _currentFilters.copyWith(speakerName: value);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Category Filter
                    if (widget.availableCategories.isNotEmpty) ...[
                      _buildFilterSection(
                        title: 'Category',
                        options: widget.availableCategories,
                        selectedValue: _currentFilters.category,
                        onSelected: (value) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(category: value);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Location Filter
                    if (widget.availableLocations.isNotEmpty) ...[
                      _buildFilterSection(
                        title: 'Location',
                        options: widget.availableLocations,
                        selectedValue: _currentFilters.location,
                        onSelected: (value) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(location: value);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Clear All',
                    onPressed: () {
                      _titleController.clear();
                      _speakerController.clear();
                      setState(() {
                        _currentFilters = FilterOptions();
                      });
                      widget.onClearFilters();
                    },
                    backgroundColor: AppColors.whiteColor,
                    textColor: AppColors.primaryColor,
                    borderColor: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      widget.onApplyFilters(_currentFilters);
                      Navigator.of(context).pop();
                    },
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onSelected(isSelected ? '' : option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: AppText(
                  text: option,
                  fontSize: 14,
                  color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFilter({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hintText: hintText,
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _speakerController.dispose();
    super.dispose();
  }
}