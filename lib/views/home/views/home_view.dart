import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_type/common/custom_nav_bar_items.dart';
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
  // final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  final viralController = Get.put(ViralController());
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  final storage = GetStorage();

  final controller = Get.put(HomeController());

  List<Widget> _buildScreens() {
    return [
      MainView(),
      ViralView(),
      const NotificationView(),
      ProfileView(),
    ];
  }

  // List appViews = [
  //   MainView(),
  //   ViralView(),
  //   const NotificationView(),
  //   ProfileView(),
  // ];
  RxBool homeSelected = true.obs;
  RxBool viralSelected = false.obs;
  RxBool notificationSelected = false.obs;
  RxBool profileSelected = false.obs;
  clearAll() {
    homeSelected.value = false;
    viralSelected.value = false;
    notificationSelected.value = false;
    profileSelected.value = false;
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        onPressed: (__) {
          clearAll();
          homeSelected.value = true;
          controller.bottomNavController.jumpToTab(0);
        },
        icon: Obx(
          () => Image.asset(
            "assets/images/png/bottom_nav_home.png",
            height: 68.sp,
            width: 68.sp,
            color: homeSelected.value ? Color(0xFFEFFFC0) : Colors.white,
          ),
        ),
        title: ("Main"),
        activeColorPrimary: const Color(0xFFEFFFC0),
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        onPressed: (__) {
          clearAll();
          viralSelected.value = true;
          controller.bottomNavController.jumpToTab(1);
        },
        icon: Obx(
          () => Image.asset(
            "assets/images/png/bottom_nav_viral.png",
            height: 68.sp,
            width: 68.sp,
            color: viralSelected.value ? Color(0xFFEFFFC0) : Colors.white,
          ),
        ),
        title: ("Viral"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      PersistentBottomNavBarItem(
        onPressed: (__) {
          clearAll();
          notificationSelected.value = true;
          controller.bottomNavController.jumpToTab(2);
        },
        icon: Obx(
          () => Image.asset(
            "assets/images/png/bottom_nav_notification.png",
            height: 68.sp,
            width: 68.sp,
            color:
                notificationSelected.value ? Color(0xFFEFFFC0) : Colors.white,
          ),
        ),
        title: ("Notification"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      //efffc0
      PersistentBottomNavBarItem(
        onPressed: (__) {
          clearAll();
          profileSelected.value = true;
          controller.bottomNavController.jumpToTab(3);
        },
        icon: Obx(
          () => Image.asset(
            "assets/images/png/bottom_nav_profile.png",
            height: 68.sp,
            width: 68.sp,
            color: profileSelected.value ? Color(0xFFEFFFC0) : Colors.white,
          ),
        ),
        title: ("Profile"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     body: Obx(() => PageStorage(
    //         bucket: _pageStorageBucket,
    //         child: appViews[controller.appView.value])),
    //     bottomNavigationBar: Container(
    //       height: 165.h,
    //       decoration: const BoxDecoration(
    //           gradient: LinearGradient(
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               colors: [Color(0xFF3CB4FF), Color(0xFF168CFF)])),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           Obx(
    //             () => CustomNavBarItems(
    //               isSelected: controller.appView.value == 0,
    //               icnPath: "assets/images/png/follow_icon.png",
    //               viewName: 'Home',
    //               onPressed: () {
    //                 controller.appView.value = 0;
    //               },
    //               height: 14,
    //             ),
    //           ),
    //           Obx(
    //             () => CustomNavBarItems(
    //               isSelected: controller.appView.value == 1,
    //               icnPath: "assets/images/png/follow_icon.png",
    //               viewName: 'Consult',
    //               onPressed: () {
    //                 controller.appView.value = 1;
    //               },
    //               height: 14,
    //             ),
    //           ),
    //           Obx(
    //             () => CustomNavBarItems(
    //               isSelected: controller.appView.value == 2,
    //               icnPath: "assets/images/png/follow_icon.png",
    //               viewName: 'Test',
    //               onPressed: () {
    //                 controller.appView.value = 2;
    //               },
    //               height: 14,
    //             ),
    //           ),
    //           Obx(
    //             () => CustomNavBarItems(
    //               isSelected: controller.appView.value == 3,
    //               icnPath: "assets/images/png/follow_icon.png",
    //               viewName: 'Guides',
    //               onPressed: () {
    //                 controller.appView.value = 3;
    //               },
    //               height: 14,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ));
    return PersistentTabView(
      context,
      controller: controller.bottomNavController,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: const Color(0xFF807e7c),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style5,
    );
  }
}
