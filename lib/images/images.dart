import 'package:flutter/material.dart';

class Images {
  static const String splashLogo = 'assets/al_sharq_logo.png';
  static const String splashBackground = 'assets/splash_logo.png';
  static const String signup_profile_image = 'assets/signup_profile_image.png';
  static const String googleimage = 'assets/google.png';
  static const String facebookimage = 'assets/Facebook.png';
  static const String appleimage = 'assets/apple.png';

  static const String alsharqLogo = 'assets/al sharq guidelines-3 copy.png';

  /// Icons...........////
  static const String myAgenda = "assets/icons/myagenda.png";
  static const String schedule = "assets/icons/schedule.png";
  static const String speaker = "assets/icons/speakers.png";
  static const String sponser = "assets/icons/sponser.png";
  static const String networking = "assets/icons/networking.png";
  static const String forums = "assets/icons/forums.png";
  static const String schedule11 = "assets/icons/schedule11.png";
  static const String drjohnthan = "assets/icons/dr.johnthan.png";
  static const String session = "assets/icons/i.png";
  static const String sendIcons = "assets/icons/send_icon.png";
  static const String linkedIn = "assets/icons/linkedin.png";
  static const String website = "assets/icons/website.png";
  static const String mailimage = "assets/icons/mail.png";
  static const String linkedin2 = "assets/icons/linkedin2.png";
  static const String twitterIcon = "assets/icons/twitter.png";
  static const String youtube = "assets/icons/youtube.png";

  /// Utility method for loading images with optional color
  static Widget load(String path, {double? width, double? height, Color? color, BoxFit fit = BoxFit.contain}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      color: color, // agar color pass karenge to tint ho jayega
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      fit: fit,
    );
  }
}
