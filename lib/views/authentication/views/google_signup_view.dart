import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class GoogleSignUpView extends StatefulWidget {
  GoogleSignUpView({super.key});

  @override
  State<GoogleSignUpView> createState() => _GoogleSignUpViewState();
}

class _GoogleSignUpViewState extends State<GoogleSignUpView> {
  final controller = Get.put(AuthenticationController());

  TextEditingController googleNameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    googleNameController.addListener(() {
      isNext.value = googleNameController.text.isNotEmpty;
    });
    super.initState();
  }

  RxBool isNext = false.obs;
  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 64.h,
            ),
            Text(
              "Register with Google",
              style: CustomTexts.font24.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 52.h,
            ),
            TextField(
              controller: googleNameController,
              style: CustomTexts.font14
                  .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
              decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: CustomTexts.font14.copyWith(
                    fontWeight: FontWeight.w400, color: CustomColors.textColor),
              ),
            ),
            SizedBox(
              height: 45.h,
            ),
            ZoomTapAnimation(
              onTap: () async {
                if (isLoading.value) {
                } else {
                  // controller.isGoogleRegisterActive()
                  //     ? await AuthService().addGoogleUser()
                  //     : null;
                  if (isNext.value) {
                    isLoading.value = true;
                    final storage = GetStorage();
                    FirebaseAuth auth = FirebaseAuth.instance;
                    final authController = Get.put(AuthenticationController());
                    String uid = auth.currentUser!.uid;

                    print(authController.nameController);
                    await AuthService().addUserToFirestore(uid,
                        auth.currentUser!.email, googleNameController.text);
                    await storage.write("uid", uid);
                    await storage.write('isSignInDone', true);
                    isLoading.value = false;
                    Get.offAll(() => HomeView());
                  } else {}
                }
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    color: isNext.value
                        ? CustomColors.activeColor
                        : CustomColors.inactiveColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.5.h),
                    child: Center(
                      child: isLoading.value
                          ? SizedBox(
                              height: 18.sp,
                              width: 18.sp,
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : Text(
                              "Register with Google",
                              style: isNext.value
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
          ],
        ),
      )),
    );
  }
}
