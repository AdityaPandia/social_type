import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.put(HomeController()).index.value = 0;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF101010),
          title: Center(
            child: Image.asset(
              "assets/images/png/onboarding_khe.png",
              color: Colors.white,
              width: 219.w,
              height: 90.h,
            ),
          ),
        ),
        body: Column(
          children: [
            FutureBuilder(
                future: Get.put(AppController())
                    .getUsername(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "@${snapshot.data.toString()}'s pending friend request",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 40.sp),
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
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text('No data available'),
                    );
                  }

                  // Extract requests array from the user document
                  final requests = snapshot.data!.get('requests');

                  return requests.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(
                              bottom: 1100.h, left: 60.w, right: 60.w),
                          constraints: BoxConstraints(maxHeight: 536.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.w),
                            color: Color(0xFF353535),
                          ),
                          child: Column(children: [
                            SizedBox(
                              height: 58.h,
                            ),
                            Text(
                              "Up to date!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 64.sp,
                                color: Color(0xFFC6C6C6),
                              ),
                            ),
                            SizedBox(
                              height: 68.h,
                            ),
                            Text(
                              "You already accept/deny all your friends request",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 60.sp, color: Color(0xFFC6C6C6)),
                            )
                          ]),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            // Display each request
                            return ListTile(
                              // title: Text(
                              //   requests[index],
                              //   style: TextStyle(color: Colors.white),
                              // ),
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      FutureBuilder(
                                          future: Get.put(AppController())
                                              .getUserProfilePhoto(
                                                  requests[index]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        200.w),
                                                child: SizedBox(
                                                  height: 120.sp,
                                                  width: 120.sp,
                                                  child: CachedNetworkImage(
                                                    placeholder:
                                                        (context, val) {
                                                      return SizedBox(
                                                        width: 31.w,
                                                        child: Center(
                                                          child: Text(
                                                            "Loading",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    imageUrl: snapshot.data
                                                        .toString(),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return SizedBox(
                                                width: 12.sp,
                                                height: 12.sp,
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      CustomColors.textColor2,
                                                ),
                                              );
                                            }
                                          }),
                                      SizedBox(
                                        width: 25.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder(
                                              future: Get.put(AppController())
                                                  .getUserName(requests[index]),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  return Opacity(
                                                    opacity: 0.7,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 30.w,
                                                              vertical: 5.h),
                                                      child: Text(
                                                        "${snapshot.data}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 40.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    width: 12.sp,
                                                    height: 12.sp,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: CustomColors
                                                          .textColor2,
                                                    ),
                                                  );
                                                }
                                              }),
                                          FutureBuilder(
                                              future: Get.put(AppController())
                                                  .getUsername(requests[index]),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  return Opacity(
                                                    opacity: 0.7,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 30.w,
                                                              vertical: 5.h),
                                                      child: Text(
                                                        "@${snapshot.data}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 24.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    width: 12.sp,
                                                    height: 12.sp,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: CustomColors
                                                          .textColor2,
                                                    ),
                                                  );
                                                }
                                              }),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 220.w,
                                      ),
                                      ZoomTapAnimation(
                                        onTap: () async {
                                          //add this request to follower
                                          String currentUserId = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          DocumentReference uidReferene =
                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid);
                                          DocumentSnapshot uidSnapshot =
                                              await uidReferene.get();
                                          Map<String, dynamic> uidData =
                                              uidSnapshot.data() as Map<String,
                                                      dynamic>? ??
                                                  {};
//
                                          List<dynamic> followers =
                                              uidData['followers'] ?? [];
                                          if (!followers
                                              .contains(requests[index])) {
                                            followers.add(requests[index]);
                                            await uidReferene.update(
                                                {'followers': followers});
                                          } else {}
                                          DocumentReference
                                              currentUserReference =
                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(requests[index]);
                                          DocumentSnapshot currentUserSnapshot =
                                              await currentUserReference.get();
                                          Map<String, dynamic> currentUserData =
                                              currentUserSnapshot.data() as Map<
                                                      String, dynamic>? ??
                                                  {};
                                          List<dynamic> following =
                                              currentUserData['following'] ??
                                                  [];
                                          following.add(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          await currentUserReference
                                              .update({'following': following});
//remove this request
                                          List<dynamic> req =
                                              uidData['requests'] ?? [];
                                          if (req.contains(requests[index])) {
                                            req.remove(requests[index]);
                                            await uidReferene
                                                .update({'requests': req});
                                          } else {}
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFCAE08A)),
                                          height: 100.sp,
                                          width: 100.sp,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/images/png/tick_logo.png",
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 31.w,
                                      ),
                                      ZoomTapAnimation(
                                        onTap: () async {
                                          String currentUserId = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          DocumentReference uidReferene =
                                              FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid);
                                          DocumentSnapshot uidSnapshot =
                                              await uidReferene.get();
                                          Map<String, dynamic> uidData =
                                              uidSnapshot.data() as Map<String,
                                                      dynamic>? ??
                                                  {};
                                          List<dynamic> req =
                                              uidData['requests'] ?? [];
                                          if (req.contains(requests[index])) {
                                            req.remove(requests[index]);
                                            await uidReferene
                                                .update({'requests': req});
                                          } else {}
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFA7A7),
                                          ),
                                          height: 100.sp,
                                          width: 100.sp,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/images/png/cross_logo.png",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
