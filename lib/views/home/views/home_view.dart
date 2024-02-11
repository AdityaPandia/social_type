import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_type/common/floating_navbar.dart';
import 'package:social_type/common/floating_navbar_item.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/notification/views/notification_view.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:social_type/views/home/views/viral/controllers/viral_controller.dart';
import 'package:social_type/views/home/views/viral/views/viral_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final viralController = Get.put(ViralController());
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  final storage = GetStorage();

  final controller = Get.put(HomeController());

  // List<Widget> _buildScreens() {
  //   return [
  //     MainView(),
  //     ViralView(),
  //     const NotificationView(),
  //     ProfileView(
  //       userUid: FirebaseAuth.instance.currentUser!.uid,
  //     ),
  //   ];
  // }
  List<Widget> buildScreens = [
    MainView(),
    ViralView(),
    NotificationView(),
    ProfileView(userUid: FirebaseAuth.instance.currentUser!.uid),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset(
          "assets/images/png/bottom_nav_home.png",
          color: Colors.white,
          height: 68.sp,
          width: 68.sp,
        ),
        title: ("Main"),
        activeColorPrimary: const Color(0xFFEFFFC0),
        activeColorSecondary: Color(0xFFEFFFC0),
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          "assets/images/png/bottom_nav_viral.png",
          height: 75.sp,
          width: 75.sp,
        ),
        title: ("Viral"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          "assets/images/png/bottom_nav_notification.png",
          height: 75.sp,
          width: 75.sp,
        ),
        title: ("Notification"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      //efffc0
      PersistentBottomNavBarItem(
        icon: Image.asset(
          "assets/images/png/bottom_nav_profile.png",
          height: 100.sp,
          width: 100.sp,
        ),
        title: ("Profile"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: buildScreens[controller.index.value],
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 60.h),
          child: FloatingNavbar(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            margin: EdgeInsets.symmetric(horizontal: 50.w),
            fontSize: 0.sp,
            selectedBackgroundColor: Color(0xFF494949),
            selectedItemColor: Colors.green,
            borderRadius: 200.w,
            itemBorderRadius: 200.w,
            backgroundColor: Color(0xFF494949),
            onTap: (int val) => controller.index.value = val,
            currentIndex: controller.index.value,
            items: [
              FloatingNavbarItem(
                  icon: Icons.home,
                  title: 'Home',
                  customWidget: Image.asset(
                    'assets/images/png/bottom_nav_home.png',
                    color: controller.index.value == 0
                        ? Color(0xFFEFFFC0)
                        : Colors.white,
                    height: 72.h,
                    width: 62.w,
                  )),
              FloatingNavbarItem(
                icon: Icons.explore,
                title: 'Explore',
                customWidget: Image.asset(
                  'assets/images/png/bottom_nav_viral.png',
                  color: controller.index.value == 1
                      ? Color(0xFFEFFFC0)
                      : Colors.white,
                  height: 69.h,
                  width: 69.w,
                ),
              ),
              FloatingNavbarItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chats',
                  customWidget: Image.asset(
                    'assets/images/png/bottom_nav_notification.png',
                    color: controller.index.value == 2
                        ? Color(0xFFEFFFC0)
                        : Colors.white,
                    height: 68.h,
                    width: 68.w,
                  )),
              FloatingNavbarItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  customWidget: Image.asset(
                    'assets/images/png/bottom_nav_profile.png',
                    color: controller.index.value == 3
                        ? Color(0xFFEFFFC0)
                        : Colors.white,
                    height: 99.h,
                    width: 99.w,
                  )),
            ],
          ),
        ),
      ),
    );

    // return PersistentTabView(
    //   context,
    //   controller: controller.bottomNavController,
    //   screens: _buildScreens(),
    //   items: _navBarsItems(),
    //   confineInSafeArea: true,
    //   backgroundColor: const Color(0xFF807e7c),
    //   handleAndroidBackButtonPress: true,
    //   resizeToAvoidBottomInset: true,
    //   stateManagement: true,
    //   hideNavigationBarWhenKeyboardShows: true,
    //   decoration: NavBarDecoration(
    //     borderRadius: BorderRadius.circular(10.0),
    //     colorBehindNavBar: Colors.white,
    //   ),
    //   popAllScreensOnTapOfSelectedTab: true,
    //   popActionScreens: PopActionScreensType.all,
    //   itemAnimationProperties: const ItemAnimationProperties(
    //     duration: Duration(milliseconds: 200),
    //     curve: Curves.ease,
    //   ),
    //   screenTransitionAnimation: const ScreenTransitionAnimation(
    //     animateTabTransition: true,
    //     curve: Curves.ease,
    //     duration: Duration(milliseconds: 200),
    //   ),
    //   navBarStyle: NavBarStyle.style5,
    // );
  }
}
