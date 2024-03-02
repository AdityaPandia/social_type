import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/model/auth_service.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isUpdateButtonActive() {
    return isUsernameActive && isNameActive ? true : false;
  }

  RxBool isLoading = false.obs;
  bool isUsernameActive = true;
  bool isNameActive = true;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _usernameController.addListener(() {
      // isUserNameDone.value = userNameController.text.isNotEmpty;
      setState(() {
        isUsernameActive = _usernameController.text.isNotEmpty;
      });
    });
    _nameController.addListener(() {
      setState(() {
        isNameActive = _nameController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    // Fetch the current user's data from Firestore
    String userId = await FirebaseAuth.instance.currentUser!
        .uid; // Replace 'user_id' with the actual UID of the user
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    // Populate the text fields with the existing name and username

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc.data()!['name'];
        _usernameController.text = userDoc.data()!['username'];
      });
    }
  }

  Future<void> _updateUserProfile() async {
    // Update the user's document in the Firestore collection
    String userId = FirebaseAuth.instance.currentUser!
        .uid; // Replace 'user_id' with the actual UID of the user
    bool userNameExist =
        await AuthService().doesUsernameExist(_usernameController.text);
    if (!userNameExist) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'name': _nameController.text,
        'username': _usernameController.text,
      });

      // Show a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
      ));
      Navigator.pop(context);
    } else {
      Get.defaultDialog(
        backgroundColor: Color(0xFF353535),
        titlePadding: EdgeInsets.only(top: 14, bottom: 8, left: 10, right: 10),
        titleStyle: GoogleFonts.poppins(
            fontSize: 54.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC6C6C6)),
        middleTextStyle:
            GoogleFonts.poppins(fontSize: 40.sp, color: Color(0xFFC6C6C6)),
        title: "Username already exists",
        middleText: "The username is already in use, please select another one",
        

        contentPadding: EdgeInsets.all(20),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 131.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 350.h,
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
                  // controller: controller.nameController,
                  controller: _nameController,
                  style: GoogleFonts.archivo(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      // hintText: "Enter you full name",
                      hintText: "¿Cúal es tu nombre?",
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
                  controller: _usernameController,
                  style: GoogleFonts.archivo(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      // hintText: "Username",
                      hintText: "¿Khé @usuario usarás?",
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
            SizedBox(
              height: 131.h,
            ),
            ZoomTapAnimation(
              onTap: () async {
                // if (controller.isActiveButtonLoading.value) {
                // } else {
                //   controller.isEmailSignUpActive()
                //       ? await AuthService().emailSignUp()
                //       : null;
                // }
                if (isLoading.value) {
                } else {
                  isLoading.value = true;
                  await _updateUserProfile();
                  isLoading.value = false;
                }
              },
              child: Center(
                child: Obx(
                  () => Container(
                      height: 150.h,
                      width: 699.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200.w),
                        color: isUpdateButtonActive()
                            ? Color(0xFFD5F600)
                            : Colors.grey,
                      ),
                      child: Center(
                        // child: controller.isActiveButtonLoading.value ?
                        child: isLoading.value
                            ? SizedBox(
                                height: 40.sp,
                                width: 40.sp,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                            : Text(
                                "Update Profile",
                                style: GoogleFonts.archivo(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48.sp,
                                    color: Colors.white),
                              ),
                        // : Text(
                        //     // "Register",
                        //     "Crear cuenta",
                        //     style: GoogleFonts.archivo(
                        //         fontWeight: FontWeight.w700,
                        //         fontSize: 48.sp,
                        //         color: Colors.white),
                        //   )
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 60.h,
            ),
          ],
        ),
      ),
    );
  }
}
