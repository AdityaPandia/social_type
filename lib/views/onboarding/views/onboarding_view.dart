import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
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
            child: Stack(
          children: [
            Image.asset(
              "assets/images/png/onboarding_background.png",
              height: 2436.h,
              width: 1125.w,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 1242.h, left: 144.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/png/onboarding_khe.png",
                      height: 106.h,
                      width: 225.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 700.w,
                          child: Text(
                            "Comparte lo que quieras cuando quieras",
                            style: GoogleFonts.poppins(
                                fontSize: 100.sp,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFEAFFBF)),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "assets/images/png/onboarding_polygon.png",
                              height: 550.h,
                              width: 250.w,
                            ),
                            SvgPicture.asset(
                              "assets/images/svg/arrow.svg",
                              height: 127.h,
                              width: 160.w,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 63.h,
                    ),
                    ZoomTapAnimation(
                      onTap: () async{
                      await storage.write('isOnboardingDone', true);
                    Get.offAll(() => LoginView());
                      },
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 400.w, maxHeight: 150.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200.w),
                          color: Color(0xFFD5F600),
                        ),
                        child: Center(
                          child: Text("Únete",
                              style: GoogleFonts.poppins(
                                  fontSize: 64.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}




/*
   await storage.write('isOnboardingDone', true);
                    Get.offAll(() => LoginView());
                    */