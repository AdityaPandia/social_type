import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:social_type/views/home/views/profile/controllers/profile_controller.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FollowerView extends StatelessWidget {
  FollowerView({required this.userUid});

  final String userUid;
  final appController = Get.put(AppController());

  Future<String?> getUidByUsername(String username) async {
    final usersRef = FirebaseFirestore.instance.collection('Users');

    final querySnapshot =
        await usersRef.where('username', isEqualTo: username).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      // Access the UID directly from the document reference
      return doc.id;
    } else {
      return null; // User not found
    }
  }

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/png/onboarding_khe.png",
            color: Colors.white,
            height: 90.h,
            width: 219.w,
          ),
          SizedBox(
            height: 50.h,
          ),
          FutureBuilder(
              future: appController.getUserName(userUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                    "${snapshot.data!}",
                    style: GoogleFonts.poppins(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF5F5F5),
                    ),
                  );
                } else {
                  return SizedBox(
                    width: 12.sp,
                    height: 12.sp,
                    child: CircularProgressIndicator(
                      color: CustomColors.textColor2,
                    ),
                  );
                }
              }),
          SizedBox(
            height: 93.h,
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(userUid)
                .get()
                .then((snapshot) => snapshot.data()!)
                .then((userDocument) {
              final followersIds =
                  (userDocument['followers'] as List<dynamic>).cast<String>();

              return Future.wait(followersIds.map((id) => FirebaseFirestore
                  .instance
                  .collection('Users')
                  .doc(id)
                  .get()
                  .then((doc) => doc.data())));
            }).then((listOfFollowerData) =>
                    listOfFollowerData.map((data) => data!).toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading followers: ${snapshot.error}');
              } else {
                final followers = snapshot.data!;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 58.w),
                  child: SizedBox(
                    height: 5000.h,
                    child: ListView.builder(
                      itemCount: followers.length,
                      itemBuilder: (context, index) {
                        final followerData = followers[index];
               
                        final followerName = followerData['name'] as String;
                        final followerPhoto =
                            followerData['profile_photo'] as String;
           
                        RxBool isF = false.obs;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 50.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  (followerPhoto == "")
                                      ? SizedBox(
                                        width: 100.w,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      )
                                      : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(2000.w),
                                        child: CachedNetworkImage(
                                          height: 100.h,
                                          width: 100.w,
                                          placeholder: (context, val) {
                                            return Container(
                                              width: 31.w,
                                              child: Center(
                                                child: Text(
                                                  "Loading",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          imageUrl: followerPhoto,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                  SizedBox(
                                    width: 58.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        followerName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 48.sp,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "@${followerData['username']}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 32.sp,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              //builder that calls function that will get uid by username

                              ZoomTapAnimation(
                                onTap: () async {
                                  String? userId = await getUidByUsername(
                                      followerData['username']);
                                  isLoading.value = true;
                                  await Get.put(MainController())
                                          .isUserIdInFollowers(
                                    userId!,
                                  )
                                      ? await Get.put(MainController())
                                          .removeUserIdFromFollowers(userId)
                                      : await Get.put(MainController())
                                          .addUserIdToFollowers(userId);
                                  isF.value
                                      ? isF.value = false
                                      : isF.value = true;
                                  isLoading.value = false;
                                },
                                child: Obx(
                                  () => Container(
                                    width: 279.w,
                                    decoration: BoxDecoration(
                                        color: isF.value
                                            ? Color(0xFFC5D6A1)
                                            : Color(0xFF817BCA),
                                        borderRadius:
                                            BorderRadius.circular(100.w)),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.w, vertical: 20.h),
                                        child: isLoading.value
                                            ? CircularProgressIndicator()
                                            : Text(
                                                isF.value
                                                    ? "Follow"
                                                    : "Unfollow",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          )
        ],
      ))),
    );
  }
}
