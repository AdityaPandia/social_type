import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:social_type/views/home/views/profile/controllers/profile_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfilePhotoView extends StatelessWidget {
  ProfilePhotoView({super.key});
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/images/png/intro_logo.png",
            width: 219.w,
            height: 80.h,
          ),
          SizedBox(
            height: 600.h,
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data!;
                final imageUrl = user['profile_photo'];
                return ZoomTapAnimation(
                  onTap: () async {
                    if (controller.isLoading.value) {
                    } else {
                      await controller.uploadProfilePhoto();
                      controller.isLoading.value = false;
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Obx(
                      () => Container(
                        height: 500.sp,
                        width: 500.sp,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: controller.isLoading.value
                            ? CircularProgressIndicator()
                            : imageUrl == ""
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 500.sp,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(1000.w),
                                    child: Image.network(
                                      imageUrl,
                                      height: 500.sp,
                                      width: 500.sp,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                );
              } else if (!snapshot.hasData) {
                return const Icon(Icons.person);
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          SizedBox(
            height: 50.h,
          ),
          SizedBox(
            width: 800.w,
            child: Text(
              "Selecciano una foto para completar tu perfil",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 48.sp, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 250.h,
          ),
          ZoomTapAnimation(
            onTap: () {
              Get.offAll(HomeView());
            },
            child: Container(
              height: 150.h,
              width: 600.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200.w),
                  color: Color(0xFFD5F600)),
              child: Center(
                child: Text(
                  "Continuar",
                  style: GoogleFonts.poppins(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
