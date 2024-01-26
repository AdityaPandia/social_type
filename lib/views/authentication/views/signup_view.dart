import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});
  final controller = Get.put(AuthenticationController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await Get.offAll(() => LoginView());
        return shouldPop!;
      },
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              ZoomTapAnimation(
                  onTap: () {
                    Get.offAll(() => LoginView());
                  },
                  child: SvgPicture.asset("assets/images/svg/back_button.svg")),
              SizedBox(
                height: 30.h,
              ),
              Text(
                "Register Now",
                style: CustomTexts.font24.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 48.h,
              ),
              Center(
                child: ZoomTapAnimation(
                  onTap: () async {
                    if (controller.isGoogleLoading.value) {
                    } else {
                      await AuthService().signInWithGoogle();
                    }
                  },
                  child: Obx(
                    () => Container(
                      width: 146.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.w),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 36.w, vertical: 11.h),
                        child: Center(
                            child: controller.isGoogleLoading.value
                                ? SizedBox(
                                    height: 18.sp,
                                    width: 18.sp,
                                    child: CircularProgressIndicator(
                                        color: CustomColors.backgroundColor),
                                  )
                                : Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/svg/google.svg"),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Text(
                                        "Google",
                                        style: CustomTexts.font12.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                    ],
                                  )),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              Center(
                child: Text(
                  "or",
                  style: CustomTexts.font14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor),
                ),
              ),
              SizedBox(
                height: 23.h,
              ),
              TextField(
                controller: controller.nameController,
                style: CustomTexts.font14
                    .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Full Name",
                  hintStyle: CustomTexts.font14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor),
                ),
              ),
              SizedBox(
                height: 32.h,
              ),
              Obx(
                () => TextField(
                  onChanged: (text) {
                    controller.isEmailValid.value =
                        RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(text);
                  },
                  controller: controller.emailController,
                  style: CustomTexts.font14.copyWith(
                      fontWeight: FontWeight.w400, color: Colors.white),
                  decoration: InputDecoration(
                    focusedBorder: controller.isEmailValid.value
                        ? const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green))
                        : null,
                    hintText: "Email ID",
                    hintStyle: CustomTexts.font14.copyWith(
                        fontWeight: FontWeight.w400,
                        color: CustomColors.textColor),
                  ),
                ),
              ),
              SizedBox(
                height: 32.h,
              ),
              TextField(
                obscureText: true,
                controller: controller.passController,
                style: CustomTexts.font14
                    .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: CustomTexts.font14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor),
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              SizedBox(
                height: 32.h,
              ),
              Obx(
                () => ZoomTapAnimation(
                  onTap: () async {
                    if (controller.isActiveButtonLoading.value) {
                    } else {
                      controller.isEmailSignUpActive()
                          ? await AuthService().emailSignUp()
                          : null;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      color: controller.isEmailSignUpActive()
                          ? CustomColors.activeColor
                          : CustomColors.inactiveColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.5.h),
                      child: Center(
                        child: controller.isActiveButtonLoading.value
                            ? SizedBox(
                                height: 18.sp,
                                width: 18.sp,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                            : Text(
                                "Register",
                                style: (controller.isEmailSignUpActive())
                                    ? CustomTexts.font14.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)
                                    : CustomTexts.font14.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: CustomColors.textColor),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: "Already have an account? ",
                    style: CustomTexts.font12.copyWith(
                        fontWeight: FontWeight.w400,
                        color: CustomColors.textColor)),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Get.delete<AuthenticationController>();
                        Get.offAll(() => LoginView());
                      },
                    text: "Login Now",
                    style: CustomTexts.font12.copyWith(
                        fontWeight: FontWeight.w500,
                        color: CustomColors.activeColor)),
              ])),
            ],
          ),
        )),
      ),
    );
  }
}
