import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_sponsor_detail_model.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organizer_sponsor_detail_viewmodel.dart';

class SponsorDetailScreen extends StatefulWidget {
  final int sponsorId;

  const SponsorDetailScreen({super.key, required this.sponsorId});

  @override
  State<SponsorDetailScreen> createState() => _SponsorDetailScreenState();
}

class _SponsorDetailScreenState extends State<SponsorDetailScreen> {
  final OrganizerSponsorDetailViewModel _detailViewModel = Get.put(OrganizerSponsorDetailViewModel());

  @override
  void initState() {
    super.initState();
    _detailViewModel.fetchSponsorDetail(widget.sponsorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Sponsor Details',
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
        if (_detailViewModel.isLoading.value && _detailViewModel.sponsorDetail.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading sponsor details...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_detailViewModel.error.isNotEmpty && _detailViewModel.sponsorDetail.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _detailViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _detailViewModel.fetchSponsorDetail(widget.sponsorId),
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        final sponsor = _detailViewModel.sponsorDetail.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sponsor Header
              _buildSponsorHeader(sponsor),
              const SizedBox(height: 24),

              // Description
              _buildSection('About', sponsor.description),
              const SizedBox(height: 24),

              // Contact Information
              if (sponsor.contacts.isNotEmpty) ...[
                _buildContactSection(sponsor.contacts),
                const SizedBox(height: 24),
              ],

              // Social Media
              if (sponsor.socialMedia.isNotEmpty) ...[
                _buildSocialMediaSection(sponsor.socialMedia),
                const SizedBox(height: 24),
              ],

              // Products/Services
              if (sponsor.products.isNotEmpty) ...[
                _buildProductsSection(sponsor.products),
                const SizedBox(height: 24),
              ],

              // Representatives
              if (sponsor.representatives.isNotEmpty) ...[
                _buildRepresentativesSection(sponsor.representatives),
                const SizedBox(height: 24),
              ],

              // Registration Date
              _buildInfoRow(
                'Registered On',
                '${sponsor.createdAt.day}/${sponsor.createdAt.month}/${sponsor.createdAt.year}',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSponsorHeader(OrganizerSponsorDetailModel sponsor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sponsor Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withOpacity(0.1),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: sponsor.picUrl != null && sponsor.picUrl!.isNotEmpty
              ? ClipOval(
            child: Image.network(
              sponsor.picUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultLogo(sponsor.name);
              },
            ),
          )
              : _buildDefaultLogo(sponsor.name),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: sponsor.name,
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
                  text: 'Sponsor',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo(String name) {
    return Center(
      child: AppText(
        text: _getInitials(name),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '??'; // Return default initials for empty names
    }

    // Split the name into words and get first letters
    List<String> words = name.trim().split(' ');

    if (words.isEmpty) {
      return '??';
    }

    // Get first letter of first word
    String firstInitial = words[0][0].toUpperCase();

    // If there's a second word, get its first letter too
    if (words.length > 1) {
      String secondInitial = words[1][0].toUpperCase();
      return '$firstInitial$secondInitial';
    }

    // If only one word, return just the first letter
    return firstInitial;
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

  Widget _buildContactSection(List<OrganizerSponsorContact> contacts) {
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

  Widget _buildContactCard(OrganizerSponsorContact contact) {
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
          if (contact.name.isNotEmpty) _buildInfoRow('Name', contact.name),
          if (contact.email.isNotEmpty) _buildInfoRow('Email', contact.email),
          if (contact.phone.isNotEmpty) _buildInfoRow('Phone', contact.phone),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection(List<OrganizerSponsorSocialMedia> socialMedia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Social Media',
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

  Widget _buildSocialMediaChip(OrganizerSponsorSocialMedia social) {
    IconData icon;
    Color color;

    switch (social.name.toLowerCase()) {
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
        text: social.name,
        fontSize: 12,
        color: Colors.white,
      ),
      backgroundColor: color,
      onPressed: () {
        // TODO: Launch URL
      },
    );
  }

  Widget _buildProductsSection(List<OrganizerSponsorProduct> products) {
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

  Widget _buildProductCard(OrganizerSponsorProduct product) {
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
            text: product.title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 4),
          AppText(
            text: product.description,
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildRepresentativesSection(List<OrganizerSponsorRepresentative> representatives) {
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

  Widget _buildRepresentativeCard(OrganizerSponsorRepresentative rep) {
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
            child: rep.user.file != null && rep.user.file!.isNotEmpty
                ? ClipOval(
              child: Image.network(
                rep.user.file!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultRepAvatar(rep.user.name);
                },
              ),
            )
                : _buildDefaultRepAvatar(rep.user.name),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: rep.user.name,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                if (rep.displayTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    text: rep.displayTitle,
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                ],
                if (rep.user.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    text: rep.user.email,
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

//
// import 'package:al_sharq_conference/sponser_view/sponser_exhibitor/session_sponsered_expension.dart';
// import 'package:flutter/material.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
//
// class SponsorDetailScreen extends StatelessWidget {
//   const SponsorDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: CustomScrollView(
//         slivers: [
//           // Header with building image and sponsor logo
//           SliverAppBar(
//             expandedHeight: 250,
//             pinned: true,
//             backgroundColor: AppColors.whiteColor,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               Container(
//                 margin: const EdgeInsets.only(right: 16, top: 8),
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.star, color: AppColors.warningColor, size: 14),
//                     const SizedBox(width: 4),
//                     const AppText(
//                       text: 'Gold Sponsors',
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 children: [
//                   // Building background image
//                   Container(
//                     width: double.infinity,
//                     height: 250,
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   // Gradient overlay
//                   Container(
//                     width: double.infinity,
//                     height: 250,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.3),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Company logo
//                   Positioned(
//                     bottom: 30,
//                     left: MediaQuery.of(context).size.width / 2 - 40,
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.blue,
//                       child: const AppText(
//                         text: 'TechCorp',
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Content
//           SliverToBoxAdapter(
//             child: Container(
//               color: AppColors.whiteColor,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//
//                   // Company Name and Description
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const AppText(
//                           text: 'TechCorp Solutions',
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                         const SizedBox(height: 16),
//                         const AppText(
//                           text: 'TechWorld Inc. is a leading provider of enterprise software solutions and digital transformation services, helping Fortune 500 companies worldwide streamline operations, enhance productivity, and embrace innovation. With decades of experience across multiple industries, TechWorld specializes in creating customized technology solutions that not only drive growth, improve customer experiences, and enable organizations to stay competitive in an ever-evolving digital landscape. Committed to excellence, TechWorld combines cutting-edge tools, expert consulting, and best-in-class support to deliver measurable business outcomes and empower companies to achieve their strategic goals.',
//                           fontSize: 13,
//                           color: AppColors.darkgrey,
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Contact Information Section
//                         const AppText(
//                           text: 'Contact Information',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildContactItem(
//                           icon: Icons.language,
//                           title: 'Website',
//                           subtitle: 'www.techcorp.com',
//                           iconColor: Colors.blue,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildContactItem(
//                           icon: Icons.email,
//                           title: 'Email',
//                           subtitle: 'contact@techcorp.com',
//                           iconColor: Colors.green,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildContactItem(
//                           icon: Icons.phone,
//                           title: 'Phone',
//                           subtitle: '+1 (555) 123-4567',
//                           iconColor: Colors.purple,
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Representatives Section
//                         const AppText(
//                           text: 'Representatives',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildRepresentative(
//                           name: 'Ahmed Al-Rashid',
//                           position: 'Tech Solutions Rep.',
//                         ),
//                         const SizedBox(height: 12),
//                         _buildRepresentative(
//                           name: 'Sarah Mitchell',
//                           position: 'Innovation Labs',
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Products & Services Section
//                   Container(
//                     width: double.infinity,
//                     color: AppColors.lightBackground,
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const AppText(
//                           text: 'Products & Services',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildServiceItem(
//                           icon: Icons.cloud,
//                           title: 'Cloud Infrastructure',
//                           description: 'Scalable cloud computing solutions for enterprise applications',
//                           iconColor: Colors.blue,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildServiceItem(
//                           icon: Icons.analytics,
//                           title: 'Data Analytics',
//                           description: 'Business intelligence and data visualization platforms',
//                           iconColor: Colors.green,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildServiceItem(
//                           icon: Icons.security,
//                           title: 'Security Solutions',
//                           description: 'Enterprise-grade security and compliance tools',
//                           iconColor: Colors.purple,
//                         ),
//                         SessionsSponsoredExtensionScreen()
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContactItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color iconColor,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: iconColor, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppText(
//               text: title,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black,
//             ),
//             AppText(
//               text: subtitle,
//               fontSize: 12,
//               color: AppColors.darkgrey,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRepresentative({required String name, required String position}) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.lightBackground,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: AppColors.primaryColor,
//             child: AppText(
//               text: name.split(' ').map((e) => e[0]).join(''),
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: name,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//                 AppText(
//                   text: position,
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               border: Border.all(color: AppColors.primaryColor),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const AppText(
//               text: 'Connect',
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildServiceItem({
//     required IconData icon,
//     required String title,
//     required String description,
//     required Color iconColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: iconColor, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: title,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//                 AppText(
//                   text: description,
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }