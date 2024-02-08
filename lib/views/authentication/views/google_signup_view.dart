import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class GoogleSignUpView extends StatelessWidget {
  GoogleSignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        showDialog(
            context: context,
            builder: (context) {
              return CommonAlertBox(
                title: "Do you want to go back to login screen?",
                onLeftTap: () async {
                  await GoogleSignIn().signOut();
                  controller.isGoogleSignupPage.value = false;
                  Navigator.pop(context);
                },
                onRightTap: () async {
                  Navigator.pop(context);
                },
              );
            });
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
            height: 160.h,
          ),
          Text(
            "Register with Google",
            style: GoogleFonts.archivo(
                fontWeight: FontWeight.bold,
                fontSize: 56.sp,
                color: Colors.white),
          ),
          SizedBox(
            height: 160.h,
          ),
          // TextField(
          //   controller: controller.googleNameController,
          //   style: CustomTexts.font14
          //       .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
          //   decoration: InputDecoration(
          //     hintText: "Full Name",
          //     hintStyle: CustomTexts.font14.copyWith(
          //         fontWeight: FontWeight.w400, color: CustomColors.textColor),
          //   ),
          // ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 6.sp, color: Colors.white),
              borderRadius: BorderRadius.circular(30.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: TextField(
                controller: controller.googleNameController,
                style: GoogleFonts.archivo(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Full Name",
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 6.sp, color: Colors.white),
              borderRadius: BorderRadius.circular(30.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: TextField(
                controller: controller.userNameController,
                style: GoogleFonts.archivo(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Username",
                    hintStyle: GoogleFonts.archivo(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white)),
              ),
            ),
          ),
          SizedBox(
            height: 250.h,
          ),
          ZoomTapAnimation(
            onTap: () async {
              if (controller.isGoogleSignupLoading.value) {
              } else {
                if (controller.isGoogleSignupNext.value &&
                    controller.isUserNameDone.value) {
                  controller.isGoogleSignupLoading.value = true;
                  final storage = GetStorage();
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final authController = Get.put(AuthenticationController());
                  String uid = auth.currentUser!.uid;

                  print(authController.nameController);
                  if(await AuthService().doesUsernameExist(authController.userNameController.text)){
                    Get.defaultDialog(title: "Username already exists");
                    controller.isGoogleSignupLoading.value=false;
                  }
                  else{
 await AuthService().addUserToFirestore(
                      uid,
                      auth.currentUser!.email,
                      controller.googleNameController.text,
                      authController.userNameController.text);
                  await storage.write("uid", uid);
                  await storage.write('isSignInDone', true).then((value) {
                    controller.isGoogleSignupLoading.value = false;
                    Get.offAll(() => HomeView());
                  }
                  );
                  };
                 
                } else {}
              }
            },
            child: Center(
              child: Obx(
                () => Container(
                    height: 150.h,
                    width: 699.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200.w),
                      color: controller.isGoogleSignupNext.value &&
                              controller.isUserNameDone.value
                          ? Color(0xFFD5F600)
                          : Colors.grey,
                    ),
                    child: Center(
                        child: controller.isGoogleSignupLoading.value
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
          // ZoomTapAnimation(
          //   onTap: () async {
          //     if (controller.isGoogleSignupLoading.value) {
          //     } else {
          //       // controller.isGoogleRegisterActive()
          //       //     ? await AuthService().addGoogleUser()
          //       //     : null;
          //       if (controller.isGoogleSignupNext.value) {
          //         controller.isGoogleSignupLoading.value = true;
          //         final storage = GetStorage();
          //         FirebaseAuth auth = FirebaseAuth.instance;
          //         final authController = Get.put(AuthenticationController());
          //         String uid = auth.currentUser!.uid;

          //         print(authController.nameController);
          //         await AuthService().addUserToFirestore(
          //             uid,
          //             auth.currentUser!.email,
          //             controller.googleNameController.text);
          //         await storage.write("uid", uid);
          //         await storage.write('isSignInDone', true);
          //         controller.isGoogleSignupLoading.value = false;
          //         Get.offAll(() => HomeView());
          //       } else {}
          //     }
          //   },
          //   child: Obx(
          //     () => Container(
          //       width: double.infinity,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(4.w),
          //         color: controller.isGoogleSignupNext.value
          //             ? CustomColors.activeColor
          //             : CustomColors.inactiveColor,
          //       ),
          //       child: Padding(
          //         padding: EdgeInsets.symmetric(vertical: 12.5.h),
          //         child: Center(
          //           child: controller.isGoogleSignupLoading.value
          //               ? SizedBox(
          //                   height: 18.sp,
          //                   width: 18.sp,
          //                   child:
          //                       CircularProgressIndicator(color: Colors.white),
          //                 )
          //               : Text(
          //                   "Register with Google",
          //                   style: controller.isGoogleSignupNext.value
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
        ],
      ),
    );
  }
}
