import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/signup_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:flutter_svg/svg.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final controller = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            SizedBox(
              height: 60.h,
            ),
            Center(
              child: SizedBox(
                height: 72.h,
                width: 82.w,
                child: Text(
                  "APP LOGO",
                  textAlign: TextAlign.center,
                  style:
                      CustomTexts.font24.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 48.h,
            ),
            ZoomTapAnimation(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 36.w, vertical: 11.h),
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
            SizedBox(
              height: 25.h,
            ),
            Text(
              "or",
              style: CustomTexts.font14.copyWith(
                  fontWeight: FontWeight.w400, color: CustomColors.textColor),
            ),
            SizedBox(
              height: 23.h,
            ),
            Obx(
              () => TextField(
                onChanged: (text) {
                  controller.isEmailValid.value =
                      RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(text);
                },
                controller: controller.emailController,
                style: CustomTexts.font14
                    .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
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
                    fontWeight: FontWeight.w400, color: CustomColors.textColor),
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: CustomTexts.font12.copyWith(
                      fontWeight: FontWeight.w400,
                      color: CustomColors.activeColor),
                )),
            SizedBox(
              height: 32.h,
            ),
            ZoomTapAnimation(
              onTap: () async {
                if (controller.isActiveButtonLoading.value) {
                } else {
                  controller.isLoginActive()
                      ? await AuthService().emailLogIn()
                      : null;
                }
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    color: controller.isLoginActive()
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
                              "Login",
                              style: (controller.isLoginActive())
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
                  text: "Don't have an account? ",
                  style: CustomTexts.font12.copyWith(
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Get.delete<AuthenticationController>();
                      Get.offAll(() => SignupView());
                    },
                  text: "Register Now",
                  style: CustomTexts.font12.copyWith(
                      fontWeight: FontWeight.w500,
                      color: CustomColors.activeColor)),
            ])),
          ],
        ),
      )),
    );
  }
}
