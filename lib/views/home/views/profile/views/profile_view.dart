import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/model/referral_system.dart';
import 'package:social_type/views/authentication/views/login_view.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/profile/controllers/profile_controller.dart';
import 'package:social_type/views/home/views/profile/views/edit_profile_view.dart';
import 'package:social_type/views/home/views/profile/views/follower_view.dart';
import 'package:social_type/views/home/views/profile/views/following_view.dart';
import 'package:social_type/views/home/views/profile/views/invitation/views/invitations_view.dart';
import 'package:social_type/views/home/views/share/views/khe_share_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileView extends StatefulWidget {
  ProfileView({required this.userUid});

  final String userUid;
  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  final controller = Get.put(ProfileController());

  RxBool isFollow2 = false.obs;
  final appController = Get.put(AppController());

  Future<void> _refreshData() async {
    // Fetch new data, update state variables, etc.
    setState(() {
      // Update state variables here
    });
  }

  var tappedProfileFollow = [].obs;

  Future<bool> checkIfUserIsVIP(String uid) async {
    bool isVIP = false;

    try {
      // Access the Firestore collection and document
      final userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      // Check if the document exists and contains the 'vip_user' field
      if (userSnapshot.exists) {
        // Retrieve the 'vip_user' field value
        final vipUser = userSnapshot.data()!['vip_user'];

        // If 'vip_user' is a boolean, set 'isVIP' accordingly
        if (vipUser is bool) {
          isVIP = vipUser;
        }
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      // Handle errors here, such as returning a default value or throwing an exception
    }
    isUserVip.value = isVIP;
    return isVIP;
  }

  RxBool isUserVerified = false.obs;
  RxBool isUserVip = false.obs;

  List<String> khePosts = [];

  Future<bool> checkIfUserIsVerified(String uid) async {
    bool isVerified = false;

    try {
      // Access the Firestore collection and document
      final userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userSnapshot.exists) {
        final verifiedUser = userSnapshot.data()!['verified_user'];

        // If 'vip_user' is a boolean, set 'isVIP' accordingly
        if (verifiedUser is bool) {
          isVerified = verifiedUser;
        }
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      // Handle errors here, such as returning a default value or throwing an exception
    }
    isUserVerified.value = isVerified;
    return isVerified;
  }

  RxBool showDailyKhe = false.obs;
  List<double> leftPosition = [30.0, 435.0, 770.0, 630.0, 242.0];
  List<double> bottomPosition = [444.0, 720.0, 444.0, 20.0, 20.0];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfUserIsVerified(widget.userUid);
    checkIfUserIsVIP(widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: Color(0xFF101010),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70.w),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 380.w,
                          ),
                          Image.asset(
                            "assets/images/png/onboarding_khe.png",
                            color: Colors.white,
                            width: 219.w,
                            height: 90.h,
                          ),
                          SizedBox(
                            width: 300.w,
                          ),
                          FirebaseAuth.instance.currentUser!.uid !=
                                  widget.userUid
                              ? SizedBox()
                              : ZoomTapAnimation(
                                  onTap: () async {
                                    await GetStorage()
                                        .write('isSignInDone', false);
                                    await GoogleSignIn().signOut();
                                    Get.offAll(() => LoginView());
                                  },
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 60.h,
                      ),
                      FutureBuilder(
                          future: appController.getUsername(widget.userUid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text(
                                "@${snapshot.data}",
                                style: GoogleFonts.poppins(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
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
                        height: 60.h,
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
                                          if (FirebaseAuth
                                                  .instance.currentUser!.uid ==
                                              widget.userUid) {
                                            await controller
                                                .uploadProfilePhoto();
                                            controller.isLoading.value = false;
                                          } else {}
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
                                          controller.isLoading.value = false;
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
                                                  alignment:
                                                      Alignment.topCenter,
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
                          SizedBox(
                            width: 20.w,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                  future:
                                      appController.getUserName(widget.userUid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Text(
                                        "${snapshot.data}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 90.sp,
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
                                height: 8.h,
                              ),
                              Obx(
                                () => Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.userUid
                                        ? ZoomTapAnimation(
                                            onTap: () {
                                              Get.to(() => EditProfileView());
                                            },
                                            child: Container(
                                              height: 101.h,
                                              width: 344.w,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD5F600),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        120.w),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Editar perfil",
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF494949)),
                                                ),
                                              ),
                                            ),
                                          )
                                        : ZoomTapAnimation(
                                            onTap: () async {
                                              if (isFollow2.value) {
                                              } else {
                                                isFollow2.value = true;
                                                if (await Get.put(
                                                        MainController())
                                                    .isUserIdInFollowers(
                                                  widget.userUid,
                                                )) {
                                                  await Get.put(
                                                          MainController())
                                                      .removeUserIdFromFollowers(
                                                          widget.userUid);
                                                } else {
                                                  tappedProfileFollow.contains(
                                                          widget.userUid)
                                                      ? tappedProfileFollow
                                                          .remove(
                                                              widget.userUid)
                                                      : tappedProfileFollow
                                                          .add(widget.userUid);
                                                  await Get.put(
                                                          MainController())
                                                      .addUserIdToFollowers(
                                                          widget.userUid);
                                                }

                                                isFollow2.value = false;
                                              }
                                            },
                                            child: Center(
                                              child: StreamBuilder(
                                                stream:
                                                    Get.put(MainController())
                                                        .isUserIdInFollowers(
                                                            widget.userUid)
                                                        .asStream(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Container(
                                                      height: 101.h,
                                                      width: 344.w,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFD5F600),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    120.w),
                                                      ),
                                                      child: Center(
                                                        child: SizedBox(
                                                            height: 40.h,
                                                            width: 20.h,
                                                            child:
                                                                const CircularProgressIndicator()),
                                                      ),
                                                    );
                                                  }

                                                  if (snapshot.data!) {
                                                    // return const Text("Unfollow",);
                                                    return Container(
                                                      height: 101.h,
                                                      width: 344.w,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFD5F600),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    120.w),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Unfollow",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                      0xFF494949)),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // return const Text("Follow");
                                                    return Obx(() =>
                                                        tappedProfileFollow
                                                                .contains(widget
                                                                    .userUid)
                                                            ? Container(
                                                                height: 101.h,
                                                                width: 344.w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xFFFFB37C),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              120.w),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Pending",
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Color(
                                                                            0xFF494949)),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 101.h,
                                                                width: 344.w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xFFD5F600),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              120.w),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Follow",
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Color(
                                                                            0xFF494949)),
                                                                  ),
                                                                ),
                                                              ));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    isUserVerified.value
                                        ? Image.asset(
                                            "assets/images/png/verified_user_icon.png",
                                            height: 100.sp,
                                            width: 100.sp,
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    isUserVip.value
                                        ? Image.asset(
                                            "assets/images/png/vip_user_icon.png",
                                            height: 100.sp,
                                            width: 100.sp,
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    FirebaseAuth.instance.currentUser!.uid !=
                                            widget.userUid
                                        ? SizedBox()
                                        : ZoomTapAnimation(
                                            onTap: () {
                                              Get.to(InvitationsView());
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: 100.sp,
                                                  width: 100.sp,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF404040),
                                                      shape: BoxShape.circle),
                                                ),
                                                Image.asset(
                                                  "assets/images/png/share_icon.png",
                                                  height: 76.sp,
                                                  width: 76.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 117.h),
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
                                    final follower =
                                        doc.get('followers').length;
                                    return ZoomTapAnimation(
                                      onTap: () {
                                        Get.to(FollowerView(
                                          userUid: widget.userUid,
                                        ));
                                        //changes
                                      },
                                      child: Text(
                                        '$follower Seguidores',
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
                                    final following =
                                        doc.get('following').length;
                                    return ZoomTapAnimation(
                                      onTap: () {
                                        Get.to(FollowingView(
                                          userUid: widget.userUid,
                                        ));
                                        //changes here
                                      },
                                      child: Text(
                                        '$following Seguidos',
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
                        height: 38.h,
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        height: 8.sp,
                      ),
                      SizedBox(
                        height: 105.h,
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: Get.put(MainController())
                        .isUserIdInFollowers(widget.userUid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData && snapshot.data != null) {
                        bool check = snapshot.data ?? false;

                        return check ||
                                widget.userUid ==
                                    FirebaseAuth.instance.currentUser!.uid
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 100.h,
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Users')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }
                                      final documents1 = snapshot.data!.docs;
                                      return Column(
                                        children: [
                                          for (int i = 0;
                                              i < documents1.length;
                                              i++) ...[
                                            documents1[i].id == widget.userUid
                                                ? SizedBox(
                                                    height: 1000.h,
                                                    child: Stack(
                                                      children: [
                                                        SizedBox(
                                                          height: 1000.h,
                                                          child: StreamBuilder(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(
                                                                      documents1[
                                                                              i]
                                                                          .id)
                                                                  .collection(
                                                                      'Posts')
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return CircularProgressIndicator();
                                                                }

                                                                final documents2 =
                                                                    snapshot
                                                                        .data!
                                                                        .docs;
                                                                final totalPosts =
                                                                    documents2
                                                                        .length;

                                                                for (int x = 0;
                                                                    x <
                                                                        documents2.length -
                                                                            1;
                                                                    x++) {
                                                                  if ((documents2[
                                                                              x]
                                                                          .id) !=
                                                                      'init') {
                                                                    khePosts.contains(documents2[x]
                                                                            [
                                                                            'post_photo'])
                                                                        ? null
                                                                        : khePosts.add(documents2[x]
                                                                            [
                                                                            'post_photo']);
                                                                  }
                                                                }
                                                                return Stack(
                                                                  children: [
                                                                    Center(
                                                                      child: totalPosts - 1 !=
                                                                              5
                                                                          ? Image
                                                                              .asset(
                                                                              "assets/images/png/post_photo_border.png",
                                                                              height: 803.sp,
                                                                              width: 803.sp,
                                                                            )
                                                                          : Image.asset(
                                                                              height: 803.sp,
                                                                              width: 803.sp,
                                                                              "assets/images/png/post_completed_border.png"),
                                                                    ),
                                                                    Stack(
                                                                      children: [
                                                                        for (int j =
                                                                                0;
                                                                            j < documents2.length - 1;
                                                                            j++) ...[
                                                                          // documents2[j].id != 'init'
                                                                          //     ?
                                                                          Positioned(
                                                                            left:
                                                                                leftPosition[j].w,
                                                                            bottom:
                                                                                bottomPosition[j].h,
                                                                            child: documents2[j].id == 'init'
                                                                                ? SizedBox()
                                                                                : ZoomTapAnimation(
                                                                                    onTap: () async {
                                                                                      await MainViewState().viewPost(documents1[i].id, j, context);
                                                                                    },
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(200.w),
                                                                                      child: SizedBox(
                                                                                        height: 275.sp,
                                                                                        width: 275.sp,
                                                                                        child: CachedNetworkImage(
                                                                                          placeholder: (context, val) {
                                                                                            return SizedBox(
                                                                                              width: 31.w,
                                                                                              child: Center(
                                                                                                child: Text(
                                                                                                  "Loading",
                                                                                                  style: TextStyle(
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    color: Colors.white,
                                                                                                    fontSize: 34.sp,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                          imageUrl: documents2[j]['post_photo'],
                                                                                          fit: BoxFit.fill,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        ]
                                                                        // for (int j = 0; j < 5; j++) ...[
                                                                        //   Positioned(
                                                                        //       left: leftPosition[j].w,
                                                                        //       bottom:
                                                                        //           bottomPosition[j].h,
                                                                        //       child: Container(
                                                                        //         height: 220.sp,
                                                                        //         width: 220.sp,
                                                                        //         color: Colors.red,
                                                                        //       )),
                                                                        // ]
                                                                      ],
                                                                    ),
                                                                    //got pasted here
                                                                    ZoomTapAnimation(
                                                                      onTap:
                                                                          () async {
                                                                        Get.to(() =>
                                                                            // UserProfileView(
                                                                            //   userUid:
                                                                            //       documents1[i]
                                                                            //           .id,
                                                                            // )
                                                                            ProfileView(userUid: documents1[i].id));
                                                                      },
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Center(
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(200.w),
                                                                                child: SizedBox(
                                                                                  height: 365.sp,
                                                                                  width: 365.sp,
                                                                                  child: documents1[i]['profile_photo'] == ""
                                                                                      ? Stack(
                                                                                          children: [
                                                                                            Center(
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: CustomColors.backgroundColor,
                                                                                                ),
                                                                                                child: Icon(
                                                                                                  Icons.person,
                                                                                                  size: 64.sp,
                                                                                                  color: CustomColors.textColor,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Align(
                                                                                              alignment: Alignment.bottomCenter,
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(bottom: 77.h),
                                                                                                child: FutureBuilder(
                                                                                                    future: Get.put(AppController()).getUsername(documents1[i].id),
                                                                                                    builder: (context, snapshot) {
                                                                                                      if (snapshot.connectionState == ConnectionState.done) {
                                                                                                        return Opacity(
                                                                                                          opacity: 0.7,
                                                                                                          child: Container(
                                                                                                            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(40.w)),

                                                                                                            // width: 350.w,
                                                                                                            child: Padding(
                                                                                                              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
                                                                                                              child: Text(
                                                                                                                "@${snapshot.data}",
                                                                                                                style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                                                                                              ),
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
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : Stack(
                                                                                          // alignment:
                                                                                          //     Alignment.center,
                                                                                          children: [
                                                                                            Center(
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(2000),
                                                                                                child: SizedBox(
                                                                                                  height: 225.sp,
                                                                                                  width: 225.sp,
                                                                                                  child: CachedNetworkImage(
                                                                                                    placeholder: (context, val) {
                                                                                                      return SizedBox(
                                                                                                        width: 31.w,
                                                                                                        child: Center(
                                                                                                          child: Text(
                                                                                                            "Loading",
                                                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34.sp, color: Colors.white),
                                                                                                          ),
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                    imageUrl: documents1[i]['profile_photo'],
                                                                                                    fit: BoxFit.fill,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Align(
                                                                                              alignment: Alignment.bottomCenter,
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(bottom: 77.h),
                                                                                                child: FutureBuilder(
                                                                                                    future: Get.put(AppController()).getUsername(documents1[i].id),
                                                                                                    builder: (context, snapshot) {
                                                                                                      if (snapshot.connectionState == ConnectionState.done) {
                                                                                                        return Opacity(
                                                                                                          opacity: 0.7,
                                                                                                          child: Container(
                                                                                                            decoration: BoxDecoration(
                                                                                                              borderRadius: BorderRadius.circular(40.w),
                                                                                                              color: Colors.grey,
                                                                                                            ),
                                                                                                            // width: 350.w,
                                                                                                            child: Padding(
                                                                                                              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
                                                                                                              child: Text(
                                                                                                                "@${snapshot.data}",
                                                                                                                style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                                                                                              ),
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
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Center(
                                                                              child: Image.asset(
                                                                                "assets/images/png/profile_photo_border.png",
                                                                                height: 325.sp,
                                                                                width: 325.sp,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ]
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.userUid)
                                          .collection('Posts')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return CircularProgressIndicator();
                                        }
                                        //                                          final snapshot1 = FirebaseFirestore.instance
                                        //     .collection('Users')
                                        //     .doc(documents1[i].id)
                                        //     .collection('Posts')
                                        //     .get();
                                        // final totalPosts = snapshot1.length - 1;

                                        final documents2 = snapshot.data!.docs;
                                        final totalPosts = documents2.length;

                                        return widget.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? Center(
                                                child: ZoomTapAnimation(
                                                  onTap: () async {
                                                    // final joinedLinks = khePosts.join(
                                                    //     '\n'); // Join links with newlines for better formatting
                                                    // await Share.share(joinedLinks,
                                                    //     subject: 'Share Links');
                                                    totalPosts - 1 == 5
                                                        ? Get.to(
                                                            () => KheShareView(
                                                                  document:
                                                                      documents2,
                                                                ))
                                                        : null;
                                                  },
                                                  child: Container(
                                                    height: 101.h,
                                                    width: 560.w,
                                                    decoration: BoxDecoration(
                                                      color: totalPosts - 1 == 5
                                                          ? Color(0xFFD5F600)
                                                          : Color(0xFF696969),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              120.w),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Comparte tu Khé diario",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF494949)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox();
                                      })
                                ],
                              )
                            : SizedBox();
                      } else {
                        return SizedBox();
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
