import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

class ExhibitorDetailScreen extends StatelessWidget {
  final String exhibitorName;
  final String exhibitorDescription;
  final String exhibitorLogo;
  final String boothNumber;
  final String hallLocation;
  final String boothSize;
  final List<Map<String, String>> contacts;
  final List<String> socialMedia;
  final List<Map<String, String>> products;
  final List<Map<String, String>> representatives;

  const ExhibitorDetailScreen({
    super.key,
    required this.exhibitorName,
    required this.exhibitorDescription,
    required this.exhibitorLogo,
    required this.boothNumber,
    required this.hallLocation,
    required this.boothSize,
    required this.contacts,
    required this.socialMedia,
    required this.products,
    required this.representatives,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Exhibitor Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exhibitor Header
            _buildExhibitorHeader(),
            const SizedBox(height: 24),

            // Description
            _buildSection('About', exhibitorDescription),
            const SizedBox(height: 24),

            // Booth Information
            _buildBoothSection(),
            const SizedBox(height: 24),

            // Contact Information
            if (contacts.isNotEmpty) ...[
              _buildContactSection(),
              const SizedBox(height: 24),
            ],

            // Social Media
            if (socialMedia.isNotEmpty) ...[
              _buildSocialMediaSection(),
              const SizedBox(height: 24),
            ],

            // Products/Services
            if (products.isNotEmpty) ...[
              _buildProductsSection(),
              const SizedBox(height: 24),
            ],

            // Representatives
            if (representatives.isNotEmpty) ...[
              _buildRepresentativesSection(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitorHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exhibitor Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withOpacity(0.1),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: ClipOval(
            child: exhibitorLogo.startsWith('http')
                ? Image.network(
              exhibitorLogo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultLogo();
              },
            )
                : _buildDefaultLogo(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: exhibitorName,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: 'Exhibitor',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (boothNumber.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    AppText(
                      text: 'Booth: $boothNumber',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Center(
      child: AppText(
        text: _getInitials(exhibitorName),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '??';
    }

    List<String> words = name.trim().split(' ');

    if (words.isEmpty) {
      return '??';
    }

    String firstInitial = words[0][0].toUpperCase();

    if (words.length > 1) {
      String secondInitial = words[1][0].toUpperCase();
      return '$firstInitial$secondInitial';
    }

    return firstInitial;
  }

  Widget _buildBoothSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Booth Information',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (boothNumber.isNotEmpty)
                _buildInfoRow('Booth Number', boothNumber),
              if (hallLocation.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Hall/Location', hallLocation),
              ],
              if (boothSize.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Booth Size', boothSize),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AppText(
            text: content,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Contact Information',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        ...contacts.map((contact) => _buildContactCard(contact)).toList(),
      ],
    );
  }

  Widget _buildContactCard(Map<String, String> contact) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((contact['name'] ?? '').isNotEmpty)
            _buildInfoRow('Name', contact['name'] ?? ''),
          if ((contact['email'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Email', contact['email'] ?? ''),
          ],
          if ((contact['phone'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Phone', contact['phone'] ?? ''),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Follow Us',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: socialMedia.map((social) => _buildSocialMediaChip(social)).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialMediaChip(String social) {
    IconData icon;
    Color color;

    switch (social.toLowerCase()) {
      case 'linkedin':
        icon = Icons.business;
        color = Colors.blue;
        break;
      case 'twitter':
        icon = Icons.chat;
        color = Colors.lightBlue;
        break;
      case 'youtube':
        icon = Icons.play_circle_fill;
        color = Colors.red;
        break;
      default:
        icon = Icons.link;
        color = Colors.grey;
    }

    return ActionChip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: AppText(
        text: social,
        fontSize: 12,
        color: Colors.white,
      ),
      backgroundColor: color,
      onPressed: () {
        // TODO: Launch URL
      },
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Products & Services',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        ...products.map((product) => _buildProductCard(product)).toList(),
      ],
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: product['title'] ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 4),
          AppText(
            text: product['description'] ?? '',
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildRepresentativesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Representatives',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        ...representatives.map((rep) => _buildRepresentativeCard(rep)).toList(),
      ],
    );
  }

  Widget _buildRepresentativeCard(Map<String, String> rep) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Representative Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
            ),
            child: (rep['image'] ?? '').isNotEmpty && (rep['image'] ?? '').startsWith('http')
                ? ClipOval(
              child: Image.network(
                rep['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultRepAvatar(rep['name'] ?? '');
                },
              ),
            )
                : _buildDefaultRepAvatar(rep['name'] ?? ''),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: rep['name'] ?? '',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                if ((rep['title'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    text: rep['title'] ?? '',
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                ],
                if ((rep['email'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    text: rep['email'] ?? '',
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultRepAvatar(String name) {
    return Center(
      child: AppText(
        text: _getInitials(name),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: '$label:',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkgrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              text: value,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}