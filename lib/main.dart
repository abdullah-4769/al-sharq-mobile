import 'package:al_sharq_conference/participants_view/splash_view/splash_view.dart';
import 'package:al_sharq_conference/utils/service_initializer.dart';
import 'package:al_sharq_conference/view_model/auth/signup_view_model.dart';
import 'package:al_sharq_conference/view_model/login_view_model.dart';
import 'package:al_sharq_conference/view_model/participant_viewmodel/event_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxOptions;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This MUST be the first thing after ensureInitialized()
  MapboxOptions.setAccessToken("pk.eyJ1Ijoicml6aWVhZ2xpbmVzIiwiYSI6ImNtaGc3aGt4bjBlb2YycnNjbDBldnh3ejUifQ.sAY7q13HBaq80LoOUAT0oQ");
  // Initialize services before running app
  await ServiceInitializer.initServices();

  // Initialize the login view model and current role
  final loginViewModel = Get.put(LoginViewModel());
  await loginViewModel.initializeCurrentRole();

  // Use Get.put() instead of Get.lazyPut() to create instance immediately
  Get.put(EventSessionsViewModel());
  Get.lazyPut(() => SignupViewModel());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Al Sharq Conference',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const SplashView(),
        );
      },
    );
  }
}