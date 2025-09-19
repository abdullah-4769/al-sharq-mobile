import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../images/images.dart';

class ConferenceLogo extends StatelessWidget {
  const ConferenceLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              Images.splashBackground,
              width: double.infinity,
              height: 127,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
            ),
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 223,
                  height: 66,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),

                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      Images.signup_profile_image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}