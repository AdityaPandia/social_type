import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/google_signup_view.dart';
import 'package:social_type/views/authentication/views/privacy_view.dart';
import 'package:social_type/views/authentication/views/signup_view.dart';
import 'package:social_type/views/authentication/views/terms_view.dart';
import 'package:video_player/video_player.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:flutter_svg/svg.dart';

class LoginView extends StatefulWidget {
  LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final controller = Get.put(AuthenticationController());
  late VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/videos/login_register_background_video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after initialization
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(
                  child: Text("Error Playing Video"),
                ),
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 131.w),
              child: SingleChildScrollView(
                  child: controller.isGoogleSignupPage.value
                      ? GoogleSignUpView()
                      : controller.isLoginPage.value
                          ? PopScope(
                              canPop: false,
                              onPopInvoked: (didPop) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CommonAlertBox(
                                        title: 'Do you want to exit?',
                                        onLeftTap: () => exit(0),
                                        onRightTap: () =>
                                            Navigator.pop(context),
                                      );
                                    });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    height: 160.h,
                                  ),
                                  Obx(
                                    () => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 6.sp,
                                            color: controller.isEmailValid.value
                                                ? Color(0xFFD5F600)
                                                : Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(30.w),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 48.w),
                                        child: TextField(
                                          onChanged: (text) {
                                            controller
                                                .isEmailValid.value = RegExp(
                                                    r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
                                                .hasMatch(text);
                                          },
                                          controller:
                                              controller.emailController,
                                          style: GoogleFonts.archivo(
                                              fontSize: 40.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  // "Introduce your email...",
                                                  "Introduce tu correo electrónico",
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
                                      border: Border.all(
                                          width: 6.sp, color: Colors.white),
                                      borderRadius: BorderRadius.circular(30.w),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 48.w),
                                      child: TextField(
                                        controller: controller.passController,
                                        obscureText: true,
                                        style: GoogleFonts.archivo(
                                            fontSize: 40.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            // hintText: "Password",
                                            hintText: "Contraseña",
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
                                        // "Forgot Password?",
                                        "¿Has olvidado tu contraseña?",
                                        style: GoogleFonts.archivo(
                                            fontSize: 36.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFD5F600)),
                                      )),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                  Text(
                                    // "or",
                                    "o",
                                    style: GoogleFonts.archivo(
                                        fontSize: 56.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 60.h,
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
                                          width: 639.w,
                                          height: 106.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.w),
                                            color: Colors.white,
                                          ),
                                          child: controller
                                                  .isGoogleLoading.value
                                              ? Center(
                                                  child: SizedBox(
                                                    height: 40.sp,
                                                    width: 40.sp,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color:
                                                                Colors.black),
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
                                                      // "Continue with Google",
                                                      "Continua con Google",
                                                      style:
                                                          GoogleFonts.archivo(
                                                              fontSize: 36.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.black),
                                                    ),
                                                  ],
                                                )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 131.h,
                                  ),
                                  ZoomTapAnimation(
                                    onTap: () async {
                                      if (controller
                                          .isActiveButtonLoading.value) {
                                      } else {
                                        controller.isLoginActive()
                                            ? await AuthService().emailLogIn()
                                            : null;
                                      }
                                    },
                                    child: Obx(
                                      () => Container(
                                          height: 150.h,
                                          width: 699.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200.w),
                                            color: controller.isLoginActive()
                                                ? Color(0xFFD5F600)
                                                : Colors.grey,
                                          ),
                                          child: Center(
                                              child: controller
                                                      .isActiveButtonLoading
                                                      .value
                                                  ? SizedBox(
                                                      height: 40.sp,
                                                      width: 40.sp,
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ))
                                                  : Text(
                                                      // "Login",
                                                      "Iniciar Sesión",
                                                      style:
                                                          GoogleFonts.archivo(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 48.sp,
                                                              color:
                                                                  Colors.white),
                                                    ))),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        // text: "Don't have an account? ",
                                        text: "¿Aún no tienes cuenta? ",
                                        style: GoogleFonts.archivo(
                                            fontSize: 36.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white)),
                                    TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // // Get.delete<AuthenticationController>();
                                            // Get.offAll(() => SignupView());
                                            controller.isLoginPage.value =
                                                false;
                                          },
                                        // text: "Register now",
                                        text: "Regístrate aquí",
                                        style: GoogleFonts.archivo(
                                            fontSize: 36.sp,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFFD5F600)))
                                  ])),
                                  SizedBox(height: 30.h),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          // text: "Don't have an account? ",
                                          text:
                                              "Cuendo creas una cuenta o inicias sesion, aceptas Ios ",
                                          style: GoogleFonts.archivo(
                                              fontSize: 36.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                      TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // // Get.delete<AuthenticationController>();
                                              // Get.offAll(() => SignupView());
                                              Get.to(() => TermsView());
                                            },
                                          // text: "Register now",
                                          text: "Terminos de uso ",
                                          style: GoogleFonts.archivo(
                                              fontSize: 36.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFFD5F600))),
                                      TextSpan(
                                          // text: "Don't have an account? ",
                                          text: "y las ",
                                          style: GoogleFonts.archivo(
                                              fontSize: 36.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                      TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // // Get.delete<AuthenticationController>();
                                              // Get.offAll(() => SignupView());
                                              Get.to(() => PrivacyView());
                                            },
                                          // text: "Register now",
                                          text: "Politicas de Privacidad",
                                          style: GoogleFonts.archivo(
                                              fontSize: 36.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFFD5F600))),
                                    ])),
                                  ),
                                ],
                              ),
                            )
                          : SignUpView()),
            ),
          ),
        ],
      ),
    );
  }
}

class CommonAlertBox extends StatelessWidget {
  const CommonAlertBox({
    super.key,
    required this.title,
    this.onLeftTap,
    this.onRightTap,
  });

  final String title;
  final Function()? onLeftTap;
  final Function()? onRightTap;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 300.h,
        width: 300.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZoomTapAnimation(onTap: onLeftTap, child: Text("Yes")),
                ZoomTapAnimation(onTap: onRightTap, child: Text("No")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
