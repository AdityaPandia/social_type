import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.put(HomeController()).index.value = 0;
      },
      child: Scaffold(
        body: SafeArea(
            child: Center(
          child: Text(
            "Notification View",
            style: CustomTexts.font24.copyWith(color: CustomColors.textColor),
          ),
        )),
      ),
    );
  }
}
