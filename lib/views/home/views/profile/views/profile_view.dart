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
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/profile/controllers/profile_controller.dart';
import 'package:social_type/views/home/views/profile/views/follower_view.dart';
import 'package:social_type/views/home/views/profile/views/following_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileView extends StatefulWidget {
  ProfileView({required this.userUid});

  final String userUid;
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = Get.put(ProfileController());

  RxBool isFollow2 = false.obs;
  final appController = Get.put(AppController());

  Future<void> _refreshData() async {
    // Fetch new data, update state variables, etc.
    setState(() {
      // Update state variables here
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
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
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(widget.userUid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final user = snapshot.data!;
                              final imageUrl = user['profile_photo'];
                              print("image url is");
                              print(imageUrl);
                              if (imageUrl != '') {
                                return Obx(
                                  () => ZoomTapAnimation(
                                    onTap: () async {
                                      if (controller.isLoading.value) {
                                      } else {
                                        await controller.uploadProfilePhoto();
                                      }
                                    },
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            width: 220.sp,
                                            height: 220.sp,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(1000.w),
                                            child: Image.network(
                                              imageUrl,
                                              height: 220.sp,
                                              width: 220.sp,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                  ),
                                );
                              } else if (imageUrl == '') {
                                return Obx(
                                  () => ZoomTapAnimation(
                                    onTap: () async {
                                      if (controller.isLoading.value) {
                                      } else {
                                        await controller.uploadProfilePhoto();
                                      }
                                    },
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            width: 220.sp,
                                            height: 220.sp,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: 220.sp,
                                                  height: 220.sp,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 120.sp,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 25.w, top: 120.h),
                                                  child: Text('Upload Photo',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 24.sp,
                                                              color: Colors
                                                                  .black)),
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
                        // ZoomTapAnimation(
                        //   onTap: ()async{
                        //    if (Get.put(ProfileController()).isLoading.value){

                        //    }else{
                        //     await Get.put(ProfileController()).uploadProfilePhoto();
                        //    }
                        //   },
                        //   child: Container(
                        //     height: 220.sp,
                        //     width: 220.sp,
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       color: Colors.grey,
                        //     ),
                        //     child: Get.put(ProfileController()).isLoading.value? CircularProgressIndicator():Icon(
                        //       Icons.person,
                        //       size: 120.sp,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          width: 20.w,
                        ),
                        FutureBuilder(
                            future: appController.getUserName(widget.userUid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return SizedBox(
                                  width: 350.w,
                                  child: Text(
                                    "${snapshot.data}",
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
                        Column(
                          children: [
                            FirebaseAuth.instance.currentUser!.uid ==
                                    widget.userUid
                                ? SizedBox()
                                : ZoomTapAnimation(
                                    onTap: () async {
                                      if (isFollow2.value) {
                                      } else {
                                        isFollow2.value = true;
                                        await Get.put(MainController())
                                                .isUserIdInFollowers(
                                          widget.userUid,
                                        )
                                            ? await Get.put(MainController())
                                                .removeUserIdFromFollowers(
                                                    widget.userUid)
                                            : await Get.put(MainController())
                                                .addUserIdToFollowers(
                                                    widget.userUid);
                                        isFollow2.value = false;
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        StreamBuilder(
                                          stream: Get.put(MainController())
                                              .isUserIdInFollowers(
                                                  widget.userUid)
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
                                              return Text(
                                                "Unfollow",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 36.sp),
                                              );
                                            } else {
                                              // return const Text("Follow");
                                              return Text(
                                                "Follow",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 36.sp),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 45.h,
                                        ),
                                      ],
                                    ),
                                  ),
                            FutureBuilder(
                                future:
                                    appController.getUsername(widget.userUid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return SizedBox(
                                      // width: 350.w,
                                      width: 250.w,
                                      child: Text(
                                        "@${snapshot.data}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 36.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
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
                          ],
                        ),
                        // SizedBox(
                        //   width: 40.w,
                        // ),
                        FirebaseAuth.instance.currentUser!.uid != widget.userUid
                            ? SizedBox()
                            : ZoomTapAnimation(
                                onTap: () async {
                                  await GetStorage()
                                      .write('isSignInDone', false);
                                  await GoogleSignIn().signOut();
                                  Get.offAll(() => LoginView());
                                },
                                child: Text(
                                  "Sign Out",
                                  style: GoogleFonts.poppins(
                                      fontSize: 24.sp, color: Colors.white),
                                ),
                              ),
                        // SizedBox(width: 5.w),
                        // Icon(
                        //   Icons.logout_outlined,
                        //   color: Colors.white,
                        //   size: 34.sp,
                        // ),
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
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              for (final doc in snapshot.data!.docs) {
                                if (doc.id == widget.userUid) {
                                  final follower = doc.get('followers').length;
                                  return ZoomTapAnimation(
                                    onTap: () {
                                      Get.to(FollowerView(
                                        userUid: widget.userUid,
                                      ));
                                      //changes
                                    },
                                    child: Text(
                                      '$follower Followers',
                                      style: GoogleFonts.poppins(
                                          fontSize: 56.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  );
                                }
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              for (final doc in snapshot.data!.docs) {
                                if (doc.id == widget.userUid) {
                                  final following = doc.get('following').length;
                                  return ZoomTapAnimation(
                                    onTap: () {
                                      Get.to(FollowingView(
                                        userUid: widget.userUid,
                                      ));
                                      //changes here
                                    },
                                    child: Text(
                                      '$following Following',
                                      style: GoogleFonts.poppins(
                                          fontSize: 56.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  );
                                }
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 42.h,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.userUid)
                      .collection('Posts')
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final documents = snapshot.data!.docs;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 58.w),
                      child: GridView.count(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 77.w,
                        crossAxisSpacing: 77.w,
                        children: List.generate(documents.length, (index) {
                          return documents[index].id != "init"
                              ? ZoomTapAnimation(
                                  onTap: () async {
                                    await MainViewState().viewPost(
                                        widget.userUid, index, context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.w),
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
                                )
                              : SizedBox();
                        }),
                      ),
                    );
                  }))
            ],
          ),
        ),
      ),
    );
  }
}
