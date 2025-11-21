
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import '../../view_model/organizer_viewmodels/organizeraddnewspeaker_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizeraddnewsponsor_viewmodel.dart';

class OrganizerAddNewSpeakerScreen extends StatefulWidget {
  final int userId;

  const OrganizerAddNewSpeakerScreen({super.key, required this.userId});

  @override
  State<OrganizerAddNewSpeakerScreen> createState() => _OrganizerAddNewSpeakerScreenState();
}

class _OrganizerAddNewSpeakerScreenState extends State<OrganizerAddNewSpeakerScreen> {
  final OrganizerAddNewSpeakerViewModel _speakerViewModel = Get.put(OrganizerAddNewSpeakerViewModel());

  final TextEditingController designationsController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController expertiseController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();

  final List<String> designationsList = [];
  final List<String> expertiseList = [];
  final List<String> tagsList = [];

  void _addDesignation() {
    if (designationsController.text.isNotEmpty) {
      setState(() {
        designationsList.add(designationsController.text.trim());
        designationsController.clear();
      });
    }
  }

  void _addExpertise() {
    if (expertiseController.text.isNotEmpty) {
      setState(() {
        expertiseList.add(expertiseController.text.trim());
        expertiseController.clear();
      });
    }
  }

  void _addTag() {
    if (tagsController.text.isNotEmpty) {
      setState(() {
        tagsList.add(tagsController.text.trim());
        tagsController.clear();
      });
    }
  }

  void _removeDesignation(int index) {
    setState(() {
      designationsList.removeAt(index);
    });
  }

  void _removeExpertise(int index) {
    setState(() {
      expertiseList.removeAt(index);
    });
  }

  void _removeTag(int index) {
    setState(() {
      tagsList.removeAt(index);
    });
  }

  bool get _isFormValid {
    return designationsList.isNotEmpty &&
        bioController.text.isNotEmpty &&
        expertiseList.isNotEmpty &&
        tagsList.isNotEmpty &&
        countryController.text.isNotEmpty;
  }

  Future<void> _createSpeaker() async {
    if (!_isFormValid) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _speakerViewModel.addNewSpeaker(
      userId: widget.userId,
      designations: designationsList,
      bio: bioController.text,
      expertise: expertiseList,
      tags: tagsList,
      country: countryController.text,
      website: websiteController.text.isEmpty ? null : websiteController.text,
      facebook: facebookController.text.isEmpty ? null : facebookController.text,
      linkedin: linkedinController.text.isEmpty ? null : linkedinController.text,
    );

    if (success) {
      // Navigate back to speakers list with success
      Get.until((route) => route.isFirst); // Go back to speakers list
      Get.snackbar(
        'Success',
        _speakerViewModel.successMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        _speakerViewModel.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: 'Add Speaker Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (_speakerViewModel.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Creating speaker...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Designations
              const AppText(
                text: 'Designations*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: designationsController,
                      hintText: 'e.g. Director of Regional Affairs',
                      onSubmitted: (_) => _addDesignation(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: _addDesignation,
                      child: const AppText(
                        text: 'Add',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (designationsList.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(designationsList.length, (index) =>
                      _buildTag(designationsList[index], () => _removeDesignation(index), Colors.blue),
                  ),
                ),

              const SizedBox(height: 20),

              // Bio
              const AppText(
                text: 'Biography*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: bioController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Enter speaker biography...',
                    hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Expertise
              const AppText(
                text: 'Areas of Expertise*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: expertiseController,
                      hintText: 'e.g. AI, Machine Learning, NLP',
                      onSubmitted: (_) => _addExpertise(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: _addExpertise,
                      child: const AppText(
                        text: 'Add',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expertiseList.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(expertiseList.length, (index) =>
                      _buildTag(expertiseList[index], () => _removeExpertise(index), Colors.green),
                  ),
                ),

              const SizedBox(height: 20),

              // Tags
              const AppText(
                text: 'Tags*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: tagsController,
                      hintText: 'e.g. workshop, keynote, panel',
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: _addTag,
                      child: const AppText(
                        text: 'Add',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tagsList.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(tagsList.length, (index) =>
                      _buildTag(tagsList[index], () => _removeTag(index), Colors.orange),
                  ),
                ),

              const SizedBox(height: 20),

              // Country
              const AppText(
                text: 'Country*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: countryController,
                hintText: 'e.g. Pakistan, USA, UK',
              ),

              const SizedBox(height: 20),

              // Website (Optional)
              const AppText(
                text: 'Website (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: websiteController,
                hintText: 'https://example.com',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 20),

              // Facebook (Optional)
              const AppText(
                text: 'Facebook (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: facebookController,
                hintText: 'https://facebook.com/username',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 20),

              // LinkedIn (Optional)
              const AppText(
                text: 'LinkedIn (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: linkedinController,
                hintText: 'https://linkedin.com/in/username',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 40),

              CustomButton(
                text: 'Create Speaker',
                onPressed: _createSpeaker,
                backgroundColor: AppColors.primaryColor,
                height: 48,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTag(String text, VoidCallback onRemove, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    designationsController.dispose();
    bioController.dispose();
    expertiseController.dispose();
    tagsController.dispose();
    countryController.dispose();
    websiteController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    super.dispose();
  }
}