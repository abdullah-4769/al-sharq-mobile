import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

class FAQSupportScreen extends StatefulWidget {
  const FAQSupportScreen({super.key});

  @override
  State<FAQSupportScreen> createState() => _FAQSupportScreenState();
}

class _FAQSupportScreenState extends State<FAQSupportScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'How do I register for the conference?',
      answer: 'You can register through our mobile app or website. Simply create an account, select your preferred sessions, and complete the payment process.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I add a session to My Agenda?',
      answer: 'Navigate to the session details page and tap the "Add to Agenda" button. You can participants_view all your added sessions in the My Agenda section.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I connect with other participants?',
      answer: 'Yes! Use our networking feature to connect with other attendees. You can send messages, schedule meetings, and join discussion forums.',
      isExpanded: true,
    ),
    FAQItem(
      question: 'Where can I find the event map?',
      answer: 'The interactive venue map is available in the Venue Maps section. It shows all halls, exhibition areas, and facilities with real-time navigation.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I participants_view speaker details?',
      answer: 'Go to the Speakers section and tap on any speaker to participants_view their full profile, including bio, sessions, and contact information.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I connect with other participants?',
      answer: 'Absolutely! Our networking platform allows you to connect with fellow attendees, speakers, and exhibitors. You can send direct messages and join group discussions.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I join virtual sessions?',
      answer: 'Yes, select sessions offer virtual participation. Look for the virtual session indicator and join through the app when the session begins.',
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: const AppText(
          text: 'FAQ & Support',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          final faqItem = faqItems[index];
          return _buildFAQCard(faqItem, index);
        },
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faqItem, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: faqItem.isExpanded,
          title: AppText(
            text: faqItem.question,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          trailing: Icon(
            faqItem.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.primaryColor,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppText(
                text: faqItem.answer,
                fontSize: 13,
                color: AppColors.darkgrey,
              ),
            ),
          ],
          onExpansionChanged: (bool expanded) {
            setState(() {
              faqItems[index].isExpanded = expanded;
            });
          },
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
  });
}