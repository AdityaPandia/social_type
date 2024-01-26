import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
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

  List<Widget> _buildScreens() {
    return [
      MainView(),
      ViralView(),
      const NotificationView(),
      ProfileView(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Main"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.fireplace_rounded),
        title: ("Viral"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.notifications),
        title: ("Notification"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: const Color(0xFFb6fa43),
        inactiveColorPrimary: const Color(0xfffcfcfc),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
      navBarStyle: NavBarStyle.style1,
    );
  }
}
