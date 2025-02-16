import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/firebase_options.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/authentication/views/signup_view.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:social_type/views/onboarding/views/onboarding_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  await ScreenUtil.ensureScreenSize();
  FlutterNativeSplash.remove();
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _configureDynamicLinks() async {
  final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  final PendingDynamicLinkData? initialLink = await dynamicLinks.getInitialLink();
  _handleDeepLink(initialLink);

  dynamicLinks.onLink.listen((PendingDynamicLinkData dynamicLink) async {
    _handleDeepLink(dynamicLink);
  });
}
void _handleDeepLink(PendingDynamicLinkData? dynamicLink) async {
  if (dynamicLink != null) {
    final Uri deepLink = dynamicLink.link;
    if (deepLink != null && deepLink.queryParameters.containsKey('invitationCode')) {
      final String invitationCode = deepLink.queryParameters['invitationCode']!;
      // Navigate to the register screen with the invitation code
    Get.to(()=>SignUpView(invitationCode: invitationCode,)); // Replace '/register' with your actual route
    }
  }
}


  final storage = GetStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    _subscribeToPostLikes();
    _setUpMessageHandling();
  }

  void _subscribeToPostLikes() {
    _firebaseMessaging.subscribeToTopic('post_likes');
  }

  void _setUpMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
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
          child: OKToast(
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
          ),
        );
      },
    );
  }
}
