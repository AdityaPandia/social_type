import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/firebase_options.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:social_type/views/onboarding/views/onboarding_view.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  await ScreenUtil.ensureScreenSize();
  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1125, 2436),
      builder: (_, __) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: GetMaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              scaffoldBackgroundColor: CustomColors.backgroundColor,
            ),
            home: AnimatedSplashScreen(
              backgroundColor: CustomColors.splashBackgroundColor,
              duration: 800,
              splash: SizedBox(
                  height: 218.h,
                  width: 532.w,
                  child: Image.asset("assets/images/png/intro_logo.png")),
              nextScreen: ((storage.read('isSignInDone') != null) &&
                      (storage.read('isSignInDone') == true))
                  ? const HomeView()
                  : ((storage.read('isOnboardingDone') != null) &&
                          (storage.read('isOnboardingDone') == true))
                      ? LoginView()
                      : (storage.read('isOnboardingDone') == null)
                          ? OnboardingView()
                          : const SizedBox(),
              splashTransition: SplashTransition.fadeTransition,
              pageTransitionType: PageTransitionType.fade,
            ),
          ),
        );
      },
    );
  }
}
