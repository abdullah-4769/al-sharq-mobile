import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class ManageFAQsScreen extends StatefulWidget {
  const ManageFAQsScreen({super.key});

  @override
  State<ManageFAQsScreen> createState() => _ManageFAQsScreenState();
}

class _ManageFAQsScreenState extends State<ManageFAQsScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: 'How do I register for the conference?',
      answer: 'You can register through our mobile app or website by creating an account and completing the payment process.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I add a session to My Agenda?',
      answer: 'Navigate to the session details page and tap the "Add to Agenda" button.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I connect with other participants?',
      answer: 'Yes! Use our networking feature to connect with other attendees, send messages, and join discussions.',
      isExpanded: true,
    ),
    FAQItem(
      question: 'Where can I find the event map?',
      answer: 'The interactive venue map is available in the Venue Maps section with real-time navigation.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I view speaker details?',
      answer: 'Go to the Speakers section and tap on any speaker to view their full profile and sessions.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I connect with other participants?',
      answer: 'Our networking platform allows you to connect with attendees, speakers, and exhibitors.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'Can I join virtual sessions?',
      answer: 'Select sessions offer virtual participation. Look for the virtual session indicator.',
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Manage FAQs',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Add FAQ Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Add FAQ',
              onPressed: () {
                _showAddFAQDialog(context);
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return _buildFAQCard(faq, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq, int index) {
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
          initiallyExpanded: faq.isExpanded,
          title: AppText(
            text: faq.question,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showEditFAQDialog(context, faq, index);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(context, index);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                faq.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppText(
                text: faq.answer,
                fontSize: 13,
                color: AppColors.darkgrey,
              ),
            ),
          ],
          onExpansionChanged: (bool expanded) {
            setState(() {
              faqs[index].isExpanded = expanded;
            });
          },
        ),
      ),
    );
  }

  void _showAddFAQDialog(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Add New FAQ',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            TextButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                  setState(() {
                    faqs.add(FAQItem(
                      question: questionController.text,
                      answer: answerController.text,
                      isExpanded: false,
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQ added successfully!')),
                  );
                }
              },
              child: const AppText(
                text: 'Add',
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditFAQDialog(BuildContext context, FAQItem faq, int index) {
    final TextEditingController questionController = TextEditingController(text: faq.question);
    final TextEditingController answerController = TextEditingController(text: faq.answer);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Edit FAQ',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            TextButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                  setState(() {
                    faqs[index] = FAQItem(
                      question: questionController.text,
                      answer: answerController.text,
                      isExpanded: faq.isExpanded,
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQ updated successfully!')),
                  );
                }
              },
              child: const AppText(
                text: 'Update',
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Delete FAQ',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: const AppText(
            text: 'Are you sure you want to delete this FAQ? This action cannot be undone.',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  faqs.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ deleted successfully!')),
                );
              },
              child: const AppText(
                text: 'Delete',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        );
      },
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