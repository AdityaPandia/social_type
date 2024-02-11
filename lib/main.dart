import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = GetStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
       _subscribeToPostLikes();
    _setUpMessageHandling();
  }

  void _subscribeToPostLikes() {
    // Subscribe to FCM topics for post likes
    // This can be based on your application's logic
    // For example, you might want to subscribe based on user's posts
    // or other criteria.
    _firebaseMessaging.subscribeToTopic('post_likes');
  }

  void _setUpMessageHandling() {
    // Set up message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Handle displaying the notification to the user
      }
    });
  }


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
              scaffoldBackgroundColor: Color(0xFF101010),
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
