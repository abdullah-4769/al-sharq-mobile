import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../../data/request_models/speaker_request_models/speaker_profile_edit_model.dart';
import '../../data/response_models/speaker_response_models/speaker_profile_show_on_dashboard_model.dart';
import '../../participants_view/profile_screen/edit_profile_view.dart';
import '../../view_model/speaker_viewmodels/speaker_profile_edit_viewmodel.dart';
import '../../view_model/speaker_viewmodels/speaker_profile_show_on_dashboard_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_update_viewmodel.dart';


class SpeakerEditProfileScreen extends StatefulWidget {
  final int speakerId;

  const SpeakerEditProfileScreen({super.key, required this.speakerId});

  @override
  State<SpeakerEditProfileScreen> createState() => _SpeakerEditProfileScreenState();
}

class _SpeakerEditProfileScreenState extends State<SpeakerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SpeakerProfileShowOnDashboardViewModel _profileViewModel;
  late final SpeakerProfileEditViewModel _editViewModel;
  late final ParticipantProfileGetViewModel _participantGetViewModel;
 // late final ParticipantProfileUpdateViewModel _participantUpdateViewModel;
  late final ParticipantProfileUpdateViewModel _participantUpdateViewModel;

// Add this variable
  bool _isEditingSpeakerProfile = true; // Add this line
  bool _isDataPopulated = false;
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _websiteController;
  late TextEditingController _youtubeController;
  late TextEditingController _facebookController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _designationsController;
  late TextEditingController _expertiseController;
  late TextEditingController _tagsController;

  File? _selectedImage;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

 // bool _isDataPopulated = false;
  void _switchToSpeakerProfile() {
    setState(() {
      _isEditingSpeakerProfile = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize ViewModels
    _profileViewModel = Get.put(SpeakerProfileShowOnDashboardViewModel());
    _editViewModel = Get.put(SpeakerProfileEditViewModel());
    _participantGetViewModel = Get.put(ParticipantProfileGetViewModel());

    _participantUpdateViewModel = Get.put(ParticipantProfileUpdateViewModel());

    _initializeControllers();
    _loadSpeakerProfile();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _countryController = TextEditingController();
    _websiteController = TextEditingController();
    _youtubeController = TextEditingController();
    _facebookController = TextEditingController();
    _linkedinController = TextEditingController();
    _twitterController = TextEditingController();
    _designationsController = TextEditingController();
    _expertiseController = TextEditingController();
    _tagsController = TextEditingController();
  }

  void _loadSpeakerProfile() {
    _profileViewModel.fetchSpeakerProfile(widget.speakerId);
  }

  void _populateFormWithData(SpeakerProfileShowOnDashboardModel speaker) {
    if (!_isDataPopulated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _nameController.text = speaker.user.name;
            _emailController.text = speaker.user.email;
            _phoneController.text = speaker.user.phone ?? '';
            _bioController.text = speaker.bio;
            _countryController.text = speaker.country;
            _websiteController.text = speaker.website ?? '';
            _youtubeController.text = speaker.youtube ?? '';
            _facebookController.text = speaker.facebook ?? '';
            _linkedinController.text = speaker.linkedin ?? '';
            _twitterController.text = speaker.twitter ?? '';
            _designationsController.text = speaker.designations.join(', ');
            _expertiseController.text = speaker.expertise.join(', ');
            _tagsController.text = speaker.tags.join(', ');
            _isDataPopulated = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _websiteController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _designationsController.dispose();
    _expertiseController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(text: 'Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const AppText(text: 'Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const AppText(text: 'Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveSpeakerProfile() async {
    if (_formKey.currentState!.validate()) {
      final requestData = SpeakerProfileEditRequestModel(
        // Remove name, email, phone as they're not in the model
        bio: _bioController.text.trim(),
        country: _countryController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        youtube: _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim(),
        facebook: _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
        linkedin: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        twitter: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
        designations: _designationsController.text.trim().isEmpty
            ? null
            : _designationsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        expertise: _expertiseController.text.trim().isEmpty
            ? null
            : _expertiseController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        tags: _tagsController.text.trim().isEmpty
            ? null
            : _tagsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      );

      // Remove speakerId parameter and await the call
      await _editViewModel.updateSpeakerProfile(requestData);

      // Refresh the profile data
      _loadSpeakerProfile();
    }
  }

  void _navigateToParticipantEdit() {
    // Navigate to participant edit profile screen
    Get.to(() => EditProfileScreen(
      currentName: _nameController.text,
      currentEmail: _emailController.text,
      currentOrganization: _participantGetViewModel.profile?.organization ?? '',
      currentImageUrl: _profileViewModel.speakerProfile?.user.file,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (_profileViewModel.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading speaker profile...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_profileViewModel.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _profileViewModel.error,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadSpeakerProfile,
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        final speaker = _profileViewModel.speakerProfile;
        if (speaker != null && !_isDataPopulated) {
          _populateFormWithData(speaker);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Switch between Participant and Speaker forms
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreyColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isEditingSpeakerProfile
                            ? const AppText(
                          key: ValueKey('speaker-text'),
                          text: 'Switch to edit Participant profile',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        )
                            : const AppText(
                          key: ValueKey('participant-text'),
                          text: 'Participant Profile',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: _isEditingSpeakerProfile
                            ? const LinearGradient(
                          colors: [AppColors.primaryColor, Color(0xFF667eea)],
                        )
                            : LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isEditingSpeakerProfile
                              ? _navigateToParticipantEdit
                              : _switchToSpeakerProfile,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isEditingSpeakerProfile
                                  ? const Row(
                                key: ValueKey('participant-button'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    text: 'Switch',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                                  : const Row(
                                key: ValueKey('speaker-button'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mic_external_on,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    text: 'Switch',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Speaker Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                                : (speaker?.user.file != null && speaker!.user.file!.isNotEmpty
                                ? Image.network(
                              speaker.user.file!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return _buildDefaultAvatar();
                              },
                            )
                                : _buildDefaultAvatar()),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.whiteColor,
                                width: 3,
                              ),
                            ),
                            child: IconButton(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Basic Information Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: 'Basic Information',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Full Name *',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Email *',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Phone',
                      controller: _phoneController,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Country *',
                      controller: _countryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your country';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Professional Information Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: 'Professional Information',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Bio *',
                      controller: _bioController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Designations (comma separated)',
                      controller: _designationsController,
                      hintText: 'e.g., AI Expert, Researcher, Professor',
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Expertise (comma separated)',
                      controller: _expertiseController,
                      hintText: 'e.g., Machine Learning, Data Science, AI',
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Tags (comma separated)',
                      controller: _tagsController,
                      hintText: 'e.g., workshop, innovation, tech',
                      validator: null,
                    ),

                    const SizedBox(height: 24),

                    // Social Media Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: 'Social Media & Links',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Website',
                      controller: _websiteController,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'LinkedIn',
                      controller: _linkedinController,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Twitter',
                      controller: _twitterController,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Facebook',
                      controller: _facebookController,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'YouTube',
                      controller: _youtubeController,
                      validator: null,
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // Fix the condition - check if isLoading is true
                          onPressed: _editViewModel.isLoading.value ? null : _saveSpeakerProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _editViewModel.isLoading.value // Add .value here
                              ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              AppText(
                                text: 'Saving...',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ],
                          )
                              : const AppText(
                            text: 'Save Changes',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 12,
          color: AppColors.darkgrey,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}