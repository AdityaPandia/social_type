import 'package:flutter/material.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Text(
          "Notification View",
          style: CustomTexts.font24.copyWith(color: CustomColors.textColor),
        ),
      )),
    );
  }
}
