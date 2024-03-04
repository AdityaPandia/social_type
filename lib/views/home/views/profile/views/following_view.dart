import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FollowingView extends StatefulWidget {
  FollowingView({required this.userUid});
  final String userUid;

  @override
  State<FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends State<FollowingView> {
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

  RxBool isF = false.obs;

  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 80.w),
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
                future: appController.getUserName(widget.userUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "Seguidos de ${snapshot.data!}",
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
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.userUid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get the list of following user IDs
                List<dynamic> following = snapshot.data!.get('following');

                return SizedBox(
                  height: 1000.h,
                  child: ListView.builder(
                    itemCount: following.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(following[index])
                            .get(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return SizedBox(); // You can show loading indicator here
                          }

                          // Get username and photo URL of the user
                          String name = userSnapshot.data!.get('name');
                          String username = userSnapshot.data!.get('username');
                          String photoURL =
                              userSnapshot.data!.get('profile_photo');

                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                height: 5.h,
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ZoomTapAnimation(
                                    onTap: () {
                                      Get.to(ProfileView(
                                          userUid: following[index]));
                                    },
                                    child: Row(
                                      children: [
                                        photoURL == ""
                                            ? SizedBox(
                                                width: 100.w,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        1000.w),
                                                child: CachedNetworkImage(
                                                  height: 110.sp,
                                                  width: 110.sp,
                                                  placeholder: (context, val) {
                                                    return Center(
                                                      child: Text(
                                                        "Loading",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  imageUrl: photoURL,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                        SizedBox(
                                          width: 25.w,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 48.sp,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(
                                              height: 15.h,
                                            ),
                                            Text("@$username",
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 36.sp,
                                                    color: Colors.white))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  FirebaseAuth.instance.currentUser!.uid ==
                                          following[index]
                                      ? SizedBox()
                                      : ZoomTapAnimation(
                                          onTap: () async {
                                            if (isLoading.value) {
                                            } else {
                                              isLoading.value = true;
                                              await Get.put(MainController())
                                                      .isUserIdInFollowers(
                                                following[index],
                                              )
                                                  ? await Get.put(
                                                          MainController())
                                                      .removeUserIdFromFollowers(
                                                          following[index])
                                                  : await Get.put(
                                                          MainController())
                                                      .addUserIdToFollowers(
                                                          following[index]);
                                              isLoading.value = false;
                                              setState(() {});
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            child: StreamBuilder(
                                              stream: Get.put(MainController())
                                                  .isUserIdInFollowers(
                                                      following[index])
                                                  .asStream(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return SizedBox(
                                                      height: 40.h,
                                                      width: 20.h,
                                                      child:
                                                          const CircularProgressIndicator());
                                                }

                                                if (snapshot.data!) {
                                                  // return const Text("Unfollow",);
                                                  return Container(
                                                    height: 110.h,
                                                    width: 279.w,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            //  Color(0xFFC5D6A1),
                                                            isLoading.value
                                                                ? Color(
                                                                    0xFF817BCA)
                                                                : Color(
                                                                    0xFF817BCA),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.w)),
                                                    child: Center(
                                                      child: Text(
                                                        "Unfollow",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  // return const Text("Follow");
                                                  return Container(
                                                    height: 110.h,
                                                    width: 279.w,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFC5D6A1),
                                                        // Color(0xFF817BCA),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.w)),
                                                    child: Center(
                                                      child: Text(
                                                        "Follow",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            // FutureBuilder<List<Map<String, dynamic>>>(
            //   future: FirebaseFirestore.instance
            //       .collection('Users')
            //       .doc(userUid)
            //       .get()
            //       .then((snapshot) => snapshot.data()!)
            //       .then((userDocument) {
            //     final followingIds =
            //         (userDocument['following'] as List<dynamic>).cast<String>();

            //     return Future.wait(followingIds.map((id) => FirebaseFirestore
            //         .instance
            //         .collection('Users')
            //         .doc(id)
            //         .get()
            //         .then((doc) => doc.data())));
            //   }).then((listOfFollowingData) =>
            //           listOfFollowingData.map((data) => data!).toList()),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error loading following: ${snapshot.error}');
            //     } else {
            //       final following = snapshot.data!;
            //       return Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 58.w),
            //         child: SizedBox(
            //           height: 5000.h,
            //           child: ListView.builder(
            //             itemCount: following.length,
            //             itemBuilder: (context, index) {
            //               final followingData = following[index];
            //               final followingName = followingData['name'] as String;
            //               final followingPhoto =
            //                   followingData['profile_photo'] as String;
            //               return Padding(
            //                 padding: EdgeInsets.only(bottom: 50.h),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Row(
            //                       children: [
            //                         (followingPhoto == "")
            //                             ? SizedBox(
            //                                 width: 100.w,
            //                                 child: Icon(
            //                                   Icons.person,
            //                                   color: Colors.white,
            //                                 ),
            //                               )
            //                             : ClipRRect(
            //                                 borderRadius:
            //                                     BorderRadius.circular(2000.w),
            //                                 child: CachedNetworkImage(
            //                                   height: 100.h,
            //                                   width: 100.w,
            //                                   placeholder: (context, val) {
            //                                     return Container(
            //                                       width: 31.w,
            //                                       child: Center(
            //                                         child: Text(
            //                                           "Loading",
            //                                           style: TextStyle(
            //                                             fontWeight:
            //                                                 FontWeight.bold,
            //                                             fontSize: 15.sp,
            //                                           ),
            //                                         ),
            //                                       ),
            //                                     );
            //                                   },
            //                                   imageUrl: followingPhoto,
            //                                   fit: BoxFit.fill,
            //                                 ),
            //                               ),
            //                         SizedBox(
            //                           width: 58.w,
            //                         ),
            //                         Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           children: [
            //                             Text(
            //                               followingName,
            //                               style: GoogleFonts.poppins(
            //                                   fontSize: 48.sp,
            //                                   color: Colors.white),
            //                             ),
            //                             Text(
            //                               "@${followingData['username']}",
            //                               style: GoogleFonts.poppins(
            //                                   fontSize: 32.sp,
            //                                   color: Colors.white),
            //                             ),
            //                           ],
            //                         ),
            //                       ],
            //                     ),
            //                     ZoomTapAnimation(
            //                       onTap: () async {
            //                         String? userId = await getUidByUsername(
            //                             followingData['username']);
            //                         isLoading.value = true;
            //                         await Get.put(MainController())
            //                                 .isUserIdInFollowers(
            //                           userId!,
            //                         )
            //                             ? await Get.put(MainController())
            //                                 .removeUserIdFromFollowers(userId)
            //                             : await Get.put(MainController())
            //                                 .addUserIdToFollowers(userId);
            //                         isF.value
            //                             ? isF.value = false
            //                             : isF.value = true;
            //                         isLoading.value = false;
            //                       },
            //                       child: Obx(
            //                         () => Container(
            //                           decoration: BoxDecoration(
            //                               color: isF.value
            //                                   ? Color(0xFFC5D6A1)
            //                                   : Color(0xFF817BCA),
            //                               borderRadius:
            //                                   BorderRadius.circular(100.w)),
            //                           child: Padding(
            //                             padding: EdgeInsets.symmetric(
            //                                 horizontal: 30.w, vertical: 20.h),
            //                             child: isLoading.value
            //                                 ? CircularProgressIndicator()
            //                                 : Text(
            //                                     isF.value ? "Follow" : "Unfollow",
            //                                     style: GoogleFonts.poppins(
            //                                         color: Colors.white),
            //                                   ),
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               );
            //             },
            //           ),
            //         ),
            //       );
            //     }
            //   },
            // )
          ],
        ),
      ))),
    );
  }
}
