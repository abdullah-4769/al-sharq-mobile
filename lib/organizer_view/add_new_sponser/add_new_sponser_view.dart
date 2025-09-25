import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class AddNewSponsorScreen extends StatefulWidget {
  const AddNewSponsorScreen({super.key});

  @override
  State<AddNewSponsorScreen> createState() => _AddNewSponsorScreenState();
}

class _AddNewSponsorScreenState extends State<AddNewSponsorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String selectedCategory = 'Gold Sponsors';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Add New Sponsor',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Sponsor Name*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter Sponsor Name',
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Contact Email*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: emailController,
              hintText: 'example@company.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Category*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: ['Gold Sponsors', 'Silver Sponsors', 'Technology', 'Exhibitors'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        text: value,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Industry / Focus*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: industryController,
              hintText: 'Technology',
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Set Password*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: passwordController,
              hintText: '••••••••',
              obscureText: true,
              suffixIcon: Icons.visibility_off,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Confirm Password*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: confirmPasswordController,
              hintText: '••••••••',
              obscureText: true,
              suffixIcon: Icons.visibility_off,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Latest Booths / Exhibitions*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const AppText(
                text: 'Innovation in Sustainable Energy',
                fontSize: 14,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Website*',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: websiteController,
              hintText: 'www.company.com',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Bio/Details*',
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
                  hintText: 'Describe your topic in detail',
                  hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const AppText(
                      text: 'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Send Email',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sponsor invitation sent successfully!')),
                      );
                    },
                    backgroundColor: AppColors.primaryColor,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    industryController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    websiteController.dispose();
    bioController.dispose();
    super.dispose();
  }
}