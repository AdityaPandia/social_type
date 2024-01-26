import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/views/authentication/views/login_view.dart';

import 'package:social_type/views/onboarding/controllers/onboarding_controller.dart';
import 'package:social_type/views/onboarding/views/widgets/build_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class OnboardingView extends StatelessWidget {
  OnboardingView({super.key});
  final controller = Get.put(OnboardingController());
  final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 500.h,
                child: PageView(
                  onPageChanged: (index) {
                    controller.isLastPage.value = (index == 1);
                  },
                  controller: controller.onboardingPageController,
                  children: const [
                    BuildPage(
                      onboardingIndex: 1,
                      title: "Onboarding Title 1",
                      subTitle: "Onboarding screen description will be here",
                    ),
                    BuildPage(
                      onboardingIndex: 2,
                      title: "Onboarding Title 2",
                      subTitle: "Onboarding screen description will be here",
                    ),
                  ],
                ),
              ),
              ZoomTapAnimation(
                onTap: () async {
                  if (controller.isLastPage.value) {
                    await storage.write('isOnboardingDone', true);
                    Get.offAll(() => LoginView());
                  } else {
                    controller.onboardingPageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.bounceIn);
                  }
                },
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.w),
                      color: CustomColors.activeColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.w, vertical: 18.h),
                      child: Text(
                        controller.isLastPage.value
                            ? "Continue to login"
                            : "Next",
                        style: CustomTexts.font16.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
