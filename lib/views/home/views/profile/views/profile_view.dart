import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/profile/controllers/profile_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());
  final appController = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/png/profile_page_background.png",
              width: 1.sw,
              height: 1125.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 70.w),
              child: Column(
                children: [
                  SizedBox(
                    height: 38.h,
                  ),
                  Row(
                    children: [
                      // Text(
                      //   "Frank A",
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 90.sp,
                      //     fontWeight: FontWeight.w600,
                      //     color: Color(0xFFF5F5F5),
                      //   ),
                      // ),
                      FutureBuilder(
                          future: appController.getUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return SizedBox(
                                width: 350.w,
                                child: Text(
                                  "${snapshot.data!}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 90.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF5F5F5),
                                  ),
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
                        width: 9.w,
                      ),
                      SizedBox(
                        width: 329.w,
                        child: Text(
                          "(@username)",
                          style: GoogleFonts.poppins(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      SizedBox(
                          width: 279.w,
                          child: Text(
                            "Follow",
                            style: GoogleFonts.poppins(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 38.h,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    height: 8.sp,
                  ),
                  SizedBox(height: 38.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "530 Followers",
                        style: GoogleFonts.poppins(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      Text(
                        "89 Following",
                        style: GoogleFonts.poppins(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                ],
              ),
            ),

            //old
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.w),
                  child: Container(
                    color: CustomColors.textColor2,
                    height: 100.sp,
                    width: 100.sp,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(GetStorage().read('uid'))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          final imageUrl = user['profile_photo'];
                          print("image url is");
                          print(imageUrl);
                          if (imageUrl != '') {
                            return Image.network(imageUrl);
                          } else if (imageUrl == '') {
                            return Obx(
                              () => ZoomTapAnimation(
                                onTap: () async {
                                  await controller.uploadProfilePhoto();
                                },
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 60.sp,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(top: 30.h),
                                              child: Text(
                                                'Upload Photo',
                                                style: CustomTexts.font12
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ); // Placeholder if no image
                          } else {
                            return const Text("Something Wrong");
                          }
                        } else if (!snapshot.hasData) {
                          return const Icon(Icons.person);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Column(
                  children: [
                    ZoomTapAnimation(
                      onTap: () {
                        Get.defaultDialog(
                            middleText: "",
                            title: "",
                            content: FutureBuilder<List<Map<String, dynamic>>>(
                              future: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get()
                                  .then((snapshot) => snapshot.data()!)
                                  .then((userDocument) {
                                final followersIds =
                                    (userDocument['followers'] as List<dynamic>)
                                        .cast<String>();

                                return Future.wait(followersIds.map((id) =>
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(id)
                                        .get()
                                        .then((doc) => doc.data())));
                              }).then((listOfFollowerData) => listOfFollowerData
                                      .map((data) => data!)
                                      .toList()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(
                                      'Error loading followers: ${snapshot.error}');
                                } else {
                                  final followers = snapshot.data!;
                                  return SizedBox(
                                    height: 300.h,
                                    width: 200.w,
                                    child: ListView.builder(
                                      itemCount: followers.length,
                                      itemBuilder: (context, index) {
                                        final followerData = followers[index];
                                        final followerName =
                                            followerData['name'] as String;
                                        return Text(followerName);
                                      },
                                    ),
                                  );
                                }
                              },
                            ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: CustomColors.greyColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 6.h),
                          child: Text(
                            "Followers",
                            style: CustomTexts.font12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    ZoomTapAnimation(
                      onTap: () {
                        Get.defaultDialog(
                            middleText: "",
                            title: "",
                            content: Container(
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .get()
                                    .then((snapshot) => snapshot.data()!)
                                    .then((userDocument) {
                                  final followingsIds =
                                      (userDocument['following']
                                              as List<dynamic>)
                                          .cast<String>();

                                  return Future.wait(followingsIds.map((id) =>
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(id)
                                          .get()
                                          .then((doc) => doc.data())));
                                }).then((listOfFollowingData) =>
                                        listOfFollowingData
                                            .map((data) => data!)
                                            .toList()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error loading followings: ${snapshot.error}');
                                  } else {
                                    final followings = snapshot.data!;
                                    return SizedBox(
                                      height: 300.h,
                                      width: 200.w,
                                      child: ListView.builder(
                                        itemCount: followings.length,
                                        itemBuilder: (context, index) {
                                          final followingData =
                                              followings[index];
                                          final followingName =
                                              followingData['name'] as String;
                                          // Use followingData and followingName to build your FollowingWidget
                                          return Text(followingName);
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: CustomColors.greyColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 6.h),
                          child: Text(
                            "Following",
                            style: CustomTexts.font12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 30.w,
                ),
                ZoomTapAnimation(
                  onTap: () async {
                    await GetStorage().write('isSignInDone', false);
                    await GoogleSignIn().signOut();
                    Get.offAll(() => LoginView());
                  },
                  child: Column(
                    children: [
                      Text(
                        "Sign Out",
                        style: CustomTexts.font12
                            .copyWith(color: CustomColors.textColor2),
                      ),
                      Icon(
                        Icons.logout_rounded,
                        color: CustomColors.backgroundColor,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            FutureBuilder(
                future: appController.getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "${snapshot.data!}",
                      style: CustomTexts.font12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.textColor2),
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
              height: 8.h,
            ),
            FutureBuilder(
                future: appController.getUserEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "${snapshot.data!}",
                      style: CustomTexts.font12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.textColor2),
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
              height: 30.h,
            ),
            Text(
              "Your Posts",
              style: CustomTexts.font18.copyWith(
                  fontWeight: FontWeight.bold, color: CustomColors.textColor),
            ),
            SizedBox(
              height: 30.h,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Posts')
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final documents = snapshot.data!.docs;
                  return SizedBox(
                    height: 300.h,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15.w,
                      crossAxisSpacing: 15.w,
                      children: List.generate(documents.length, (index) {
                        return documents[index].id != "init"
                            ? ZoomTapAnimation(
                                onTap: () async {
                                  // await _MainViewState().viewPos
                                  await MainViewState().viewPost(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      index,
                                      context);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.w),
                                  child: SizedBox(
                                    height: 120.h,
                                    width: 120.w,
                                    child: CachedNetworkImage(
                                      placeholder: (context, val) {
                                        return Container(
                                          width: 31.w,
                                          child: Center(
                                            child: Text(
                                              "Loading",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      imageUrl: documents[index]['post_photo'],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox();
                      }),
                    ),
                  );
                }))
          ],
        ),
      ),
    );
  }
}
