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
                        FutureBuilder(
                            future: appController.getUsername(widget.userUid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return SizedBox(
                                  width: 350.w,
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
                        SizedBox(
                          width: 40.w,
                        ),
                        ZoomTapAnimation(
                          onTap: () async {
                            await GetStorage().write('isSignInDone', false);
                            await GoogleSignIn().signOut();
                            Get.offAll(() => LoginView());
                          },
                          child: Text(
                            "Sign Out",
                            style: GoogleFonts.poppins(
                                fontSize: 24.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                          Icons.logout_outlined,
                          color: Colors.white,
                          size: 34.sp,
                        ),
                  
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
                      child: SizedBox(
                        height: 5000.h,
                        child: GridView.count(
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
                                        imageUrl: documents[index]
                                            ['post_photo'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : SizedBox();
                          }),
                        ),
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
