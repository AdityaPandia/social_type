import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        controller.isLoginPage.value = true;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 591.h,
          ),
          Center(
            child: Image.asset(
              "assets/images/png/onboarding_khe.png",
              width: 532.w,
              height: 218.h,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 120.h,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 6.sp, color: Colors.white),
              borderRadius: BorderRadius.circular(30.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: TextField(
                controller: controller.nameController,
                style: GoogleFonts.archivo(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter you full name",
                    hintStyle: GoogleFonts.archivo(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white)),
              ),
            ),
          ),
          SizedBox(
            height: 60.h,
          ),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 6.sp,
                    color: controller.isEmailValid.value
                        ? Color(0xFFD5F600)
                        : Colors.white),
                borderRadius: BorderRadius.circular(30.w),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: TextField(
                  onChanged: (text) {
                    controller.isEmailValid.value =
                        RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(text);
                  },
                  controller: controller.emailController,
                  style: GoogleFonts.archivo(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Introduce your email...",
                      hintStyle: GoogleFonts.archivo(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60.h,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 6.sp, color: Colors.white),
              borderRadius: BorderRadius.circular(30.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: TextField(
                controller: controller.passController,
                obscureText: true,
                style: GoogleFonts.archivo(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle: GoogleFonts.archivo(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white)),
              ),
            ),
          ),

          SizedBox(
            height: 60.h,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.archivo(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFD5F600)),
              )),
          SizedBox(
            height: 40.h,
          ),
          Center(
            child: Text(
              "or",
              style: GoogleFonts.archivo(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 40.h,
          ),
          ZoomTapAnimation(
            onTap: () async {
              if (controller.isGoogleLoading.value) {
              } else {
                await AuthService().signInWithGoogle();
              }
            },
            child: Obx(
              () => Center(
                child: Container(
                    width: 639.w,
                    height: 106.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      color: Colors.white,
                    ),
                    child: controller.isGoogleLoading.value
                        ? Center(
                            child: SizedBox(
                              height: 40.sp,
                              width: 40.sp,
                              child: CircularProgressIndicator(
                                  color: Colors.black),
                            ),
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: 31.w,
                              ),
                              SvgPicture.asset(
                                "assets/images/svg/google.svg",
                                height: 74.sp,
                                width: 74.sp,
                              ),
                              SizedBox(
                                width: 40.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "Continue with Google",
                                style: GoogleFonts.archivo(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black),
                              ),
                            ],
                          )),
              ),
            ),
          ),
          SizedBox(
            height: 131.h,
          ),
          ZoomTapAnimation(
            onTap: () async {
              if (controller.isActiveButtonLoading.value) {
              } else {
                controller.isEmailSignUpActive()
                    ? await AuthService().emailSignUp()
                    : null;
              }
            },
            child: Obx(
              () => Center(
                child: Container(
                    height: 150.h,
                    width: 699.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200.w),
                      color: controller.isEmailSignUpActive()
                          ? Color(0xFFD5F600)
                          : Colors.grey,
                    ),
                    child: Center(
                        child: controller.isActiveButtonLoading.value
                            ? SizedBox(
                                height: 40.sp,
                                width: 40.sp,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                            : Text(
                                "Register",
                                style: GoogleFonts.archivo(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48.sp,
                                    color: Colors.white),
                              ))),
              ),
            ),
          ),
          SizedBox(
            height: 60.h,
          ),
          Center(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: "Already have an account? ",
                  style: GoogleFonts.archivo(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // // Get.delete<AuthenticationController>();
                      // Get.offAll(() => SignupView());
                      controller.isLoginPage.value = true;
                    },
                  text: "Login now",
                  style: GoogleFonts.archivo(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFD5F600)))
            ])),
          ),
          //old
          // ZoomTapAnimation(
          //     onTap: () {
          //       Get.offAll(() => LoginView());
          //     },
          //     child: SvgPicture.asset("assets/images/svg/back_button.svg")),
          // SizedBox(
          //   height: 30.h,
          // ),
          // Text(
          //   "Register Now",
          //   style: CustomTexts.font24.copyWith(fontWeight: FontWeight.w700),
          // ),
          // SizedBox(
          //   height: 48.h,
          // ),
          // Center(
          //   child: ZoomTapAnimation(
          //     onTap: () async {
          //       if (controller.isGoogleLoading.value) {
          //       } else {
          //         await AuthService().signInWithGoogle();
          //       }
          //     },
          //     child: Obx(
          //       () => Container(
          //         width: 146.w,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(4.w),
          //           color: Colors.white,
          //         ),
          //         child: Padding(
          //           padding:
          //               EdgeInsets.symmetric(horizontal: 36.w, vertical: 11.h),
          //           child: Center(
          //               child: controller.isGoogleLoading.value
          //                   ? SizedBox(
          //                       height: 18.sp,
          //                       width: 18.sp,
          //                       child: CircularProgressIndicator(
          //                           color: CustomColors.backgroundColor),
          //                     )
          //                   : Row(
          //                       children: [
          //                         SvgPicture.asset(
          //                             "assets/images/svg/google.svg"),
          //                         SizedBox(
          //                           width: 10.w,
          //                         ),
          //                         Text(
          //                           "Google",
          //                           style: CustomTexts.font12.copyWith(
          //                               fontWeight: FontWeight.w400,
          //                               color: Colors.black),
          //                         ),
          //                       ],
          //                     )),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 25.h,
          // ),
          // Center(
          //   child: Text(
          //     "or",
          //     style: CustomTexts.font14.copyWith(
          //         fontWeight: FontWeight.w400, color: CustomColors.textColor),
          //   ),
          // ),
          // SizedBox(
          //   height: 23.h,
          // ),
          // TextField(
          //   controller: controller.nameController,
          //   style: CustomTexts.font14
          //       .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
          //   decoration: InputDecoration(
          //     hintText: "Full Name",
          //     hintStyle: CustomTexts.font14.copyWith(
          //         fontWeight: FontWeight.w400, color: CustomColors.textColor),
          //   ),
          // ),
          // SizedBox(
          //   height: 32.h,
          // ),
          // Obx(
          //   () => TextField(
          //     onChanged: (text) {
          //       controller.isEmailValid.value =
          //           RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(text);
          //     },
          //     controller: controller.emailController,
          //     style: CustomTexts.font14
          //         .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
          //     decoration: InputDecoration(
          //       focusedBorder: controller.isEmailValid.value
          //           ? const UnderlineInputBorder(
          //               borderSide: BorderSide(color: Colors.green))
          //           : null,
          //       hintText: "Email ID",
          //       hintStyle: CustomTexts.font14.copyWith(
          //           fontWeight: FontWeight.w400, color: CustomColors.textColor),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 32.h,
          // ),
          // TextField(
          //   obscureText: true,
          //   controller: controller.passController,
          //   style: CustomTexts.font14
          //       .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
          //   decoration: InputDecoration(
          //     hintText: "Password",
          //     hintStyle: CustomTexts.font14.copyWith(
          //         fontWeight: FontWeight.w400, color: CustomColors.textColor),
          //   ),
          // ),
          // SizedBox(
          //   height: 16.h,
          // ),
          // SizedBox(
          //   height: 32.h,
          // ),
          // Obx(
          //   () => ZoomTapAnimation(
          //     onTap: () async {
          //       if (controller.isActiveButtonLoading.value) {
          //       } else {
          //         controller.isEmailSignUpActive()
          //             ? await AuthService().emailSignUp()
          //             : null;
          //       }
          //     },
          //     child: Container(
          //       width: double.infinity,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(4.w),
          //         color: controller.isEmailSignUpActive()
          //             ? CustomColors.activeColor
          //             : CustomColors.inactiveColor,
          //       ),
          //       child: Padding(
          //         padding: EdgeInsets.symmetric(vertical: 12.5.h),
          //         child: Center(
          //           child: controller.isActiveButtonLoading.value
          //               ? SizedBox(
          //                   height: 18.sp,
          //                   width: 18.sp,
          //                   child: const CircularProgressIndicator(
          //                     color: Colors.white,
          //                   ))
          //               : Text(
          //                   "Register",
          //                   style: (controller.isEmailSignUpActive())
          //                       ? CustomTexts.font14.copyWith(
          //                           fontWeight: FontWeight.w500,
          //                           color: Colors.white)
          //                       : CustomTexts.font14.copyWith(
          //                           fontWeight: FontWeight.w500,
          //                           color: CustomColors.textColor),
          //                 ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 30.h,
          // ),
          // Text.rich(TextSpan(children: [
          //   TextSpan(
          //       text: "Already have an account? ",
          //       style: CustomTexts.font12.copyWith(
          //           fontWeight: FontWeight.w400, color: CustomColors.textColor)),
          //   TextSpan(
          //       recognizer: TapGestureRecognizer()
          //         ..onTap = () {
          //           // // Get.delete<AuthenticationController>();
          //           // Get.offAll(() => LoginView());
          //           controller.isLoginPage.value = true;
          //         },
          //       text: "Login Now",
          //       style: CustomTexts.font12.copyWith(
          //           fontWeight: FontWeight.w500,
          //           color: CustomColors.activeColor)),
          // ])),
        ],
      ),
    );
  }
}
