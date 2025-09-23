import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/participants_view/speakers_view/speaker_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../images/images.dart';

class SpeakerCard extends StatelessWidget {
  final String name;
  final String title;
  final String category;
  final String sessions;

  final String description;

  const SpeakerCard({
    required this.name,
    required this.title,
    required this.category,
    required this.sessions,
   
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker Image
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(Images.drjohnthan),
            ),
            const SizedBox(width: 12),
            // Speaker Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          Chip(
                            label: Text(category),
                            backgroundColor: category == 'Keynote Speaker'
                                ? Colors.blue[100]
                                : Colors.green[100],
                            labelStyle: TextStyle(
                              color: category == 'Keynote Speaker'
                                  ? Colors.blue[900]
                                  : Colors.green[900],
                            ),
                          ),
                          Chip(
                            label: Text(sessions),
                            backgroundColor: Colors.red[100],
                            labelStyle: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [

                      const Spacer(),
                      CustomButton(text: "Chat with $name",
                        onPressed: (){

                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle chat functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Chat with $name'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}