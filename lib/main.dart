import 'package:al_sharq_conference/participants_view/auth/app_routes.dart';
import 'package:al_sharq_conference/participants_view/splash_view/splash_view.dart';
import 'package:al_sharq_conference/utils/service_initializer.dart';
import 'package:al_sharq_conference/view_model/auth/signup_view_model.dart';
import 'package:al_sharq_conference/view_model/login_view_model.dart';
import 'package:al_sharq_conference/view_model/participant_viewmodel/event_session_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxOptions;
import 'firebase_options.dart';
import 'notifications/notification_service.dart';
import 'notifications/notification_controller.dart';

// TOP-LEVEL BACKGROUND HANDLER (MUST be at top level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📥 [Background Handler] Received message: ${message.messageId}');

  // Initialize Firebase in background
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GetX for background
  if (!Get.isRegistered<NotificationController>()) {
    Get.put(NotificationController());
  }

  // Handle the notification
  await NotificationService.firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 [main] Starting app initialization...');

  // Initialize Firebase FIRST
  print('🔥 [main] Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ [main] Firebase initialized');

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('✅ [main] Background handler registered');

  // Initialize Mapbox
  print('🗺️  [main] Initializing Mapbox...');
  MapboxOptions.setAccessToken(
      "pk.eyJ1Ijoicml6aWVhZ2xpbmVzIiwiYSI6ImNtaGc3aGt4bjBlb2YycnNjbDBldnh3ejUifQ.sAY7q13HBaq80LoOUAT0oQ");
  print('✅ [main] Mapbox initialized');

  // Initialize other services
  print('⚙️  [main] Initializing services...');
  await ServiceInitializer.initServices();
  print('✅ [main] Services initialized');

  // Initialize NotificationController (GetX controller)
  print('🎮 [main] Initializing notification controller...');
  Get.put(NotificationController());
  print('✅ [main] Notification controller initialized');

  // Initialize NotificationService AFTER Firebase and Controller
  print('🔔 [main] Initializing notification service...');
  await NotificationService.initialize();
  print('✅ [main] Notification service initialized');

  // Initialize view models
  print('📊 [main] Initializing view models...');
  final loginViewModel = Get.put(LoginViewModel());
  await loginViewModel.initializeCurrentRole();
  Get.put(EventSessionsViewModel());
  Get.lazyPut(() => SignupViewModel());
  print('✅ [main] View models initialized');

  print('✅ [main] App initialization complete\n');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Al Sharq Conference',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SplashView(),
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}



// // lib/main.dart
//
// import 'package:al_sharq_conference/participants_view/auth/app_routes.dart';
// import 'package:al_sharq_conference/participants_view/splash_view/splash_view.dart';
// import 'package:al_sharq_conference/utils/service_initializer.dart';
// import 'package:al_sharq_conference/view_model/auth/signup_view_model.dart';
// import 'package:al_sharq_conference/view_model/login_view_model.dart';
// import 'package:al_sharq_conference/view_model/participant_viewmodel/event_session_viewmodel.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxOptions;
//
// import 'notifications/notification_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   print('🚀 [main] Starting app initialization...');
//
//   // Initialize Firebase FIRST
//   print('🔥 [main] Initializing Firebase...');
//   await Firebase.initializeApp();
//   print('✅ [main] Firebase initialized');
//
//   // Initialize Mapbox
//   print('🗺️  [main] Initializing Mapbox...');
//   MapboxOptions.setAccessToken(
//       "pk.eyJ1Ijoicml6aWVhZ2xpbmVzIiwiYSI6ImNtaGc3aGt4bjBlb2YycnNjbDBldnh3ejUifQ.sAY7q13HBaq80LoOUAT0oQ");
//   print('✅ [main] Mapbox initialized');
//
//   // Initialize other services
//   print('⚙️  [main] Initializing services...');
//   await ServiceInitializer.initServices();
//   print('✅ [main] Services initialized');
//
//   // Initialize NotificationService AFTER Firebase
//   print('🔔 [main] Initializing notification service...');
//   await NotificationService.initialize();
//   print('✅ [main] Notification service initialized');
//
//   // Initialize view models
//   print('📊 [main] Initializing view models...');
//   final loginViewModel = Get.put(LoginViewModel());
//   await loginViewModel.initializeCurrentRole();
//   Get.put(EventSessionsViewModel());
//   Get.lazyPut(() => SignupViewModel());
//   print('✅ [main] View models initialized');
//
//   print('✅ [main] App initialization complete\n');
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'Al Sharq Conference',
//           theme: ThemeData(
//             colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           ),
//           home: const SplashView(),
//           getPages: AppRoutes.routes,
//         );
//       },
//     );
//   }
// }