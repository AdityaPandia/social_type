import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:social_type/views/home/views/viral/controllers/viral_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

// ignore: must_be_immutable
class SearchView extends StatefulWidget {
  SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController.addListener(() {
      controller.isSearchActive.value = (searchController.text.isNotEmpty);
    });
  }

  final controller = Get.put(ViralController());
  final mainController = Get.put(MainController());

  TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  RxBool isFollowButtonLoading = false.obs;
  var tappedFollowIcons2 = [].obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.backgroundColor,
        title: Container(
          margin: EdgeInsets.only(top: 30.h),
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(80.w)),
          child: Row(
            children: [
              SizedBox(
                width: 50.w,
              ),
              Icon(
                Icons.search_rounded,
                color: CustomColors.backgroundColor,
              ),
              SizedBox(
                width: 50.w,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 600.w,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        // hintText: "Search User...",
                        hintText: "Buscar usuario…",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            SizedBox(
              height: 100.h,
            ),
            controller.isSearchActive.value
                ? StreamBuilder(
                    stream: _searchQuery.isEmpty
                        ? FirebaseFirestore.instance
                            .collection('Users')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('Users')
                            .where('username',
                                isGreaterThanOrEqualTo: _searchQuery)
                            .where('username', isLessThan: _searchQuery + 'z')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No users found'),
                        );
                      }

                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var user = snapshot.data!.docs[index];
                            return ListTile(
                              title: ZoomTapAnimation(
                                onTap: () {
                                  Get.to(() => ProfileView(userUid: user.id));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      height: 3.h,
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            user['profile_photo'] != ""
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000.w),
                                                    child: Image.network(
                                                      user['profile_photo'],
                                                      height: 100.sp,
                                                      width: 100.sp,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                            SizedBox(
                                              width: 25.w,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      user['name'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 40.sp,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    SizedBox(
                                                      width: 20.w,
                                                    ),
                                                    user['vip_user']
                                                        ? Image.asset(
                                                            "assets/images/png/vip_user_icon.png",
                                                            height: 45.sp,
                                                            width: 45.sp,
                                                          )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: 20.w,
                                                    ),
                                                    user['verified_user']
                                                        ? Image.asset(
                                                            "assets/images/png/verified_user_icon.png",
                                                            height: 45.sp,
                                                            width: 45.sp,
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                                Text(
                                                  user['username'],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 26.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        ZoomTapAnimation(
                                          onTap: () async {
                                            isFollowButtonLoading.value = true;
                                            await mainController
                                                    .isUserIdInFollowers(
                                              user.id,
                                            )
                                                ? await mainController
                                                    .removeUserIdFromFollowers(
                                                        user.id)
                                                : await mainController
                                                    .addUserIdToFollowers(
                                                        user.id);
                                            isFollowButtonLoading.value = false;
                                            tappedFollowIcons2.contains(user.id)
                                                ? tappedFollowIcons2
                                                    .remove(user.id)
                                                : tappedFollowIcons2
                                                    .add(user.id);
                                          },
                                          child: Obx(
                                            () => Center(
                                              child: isFollowButtonLoading.value
                                                  ? SizedBox(
                                                      height: 40.h,
                                                      width: 20.h,
                                                      child:
                                                          const CircularProgressIndicator())
                                                  : StreamBuilder(
                                                      stream: mainController
                                                          .isUserIdInFollowers(
                                                              user.id)
                                                          .asStream(),
                                                      builder:
                                                          (context, snapshot) {
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
                                                              height: 75.h,
                                                              width: 290.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100.w),
                                                                color: Color(
                                                                    0xFF817BCA),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  "Unfollow",
                                                                  style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          32.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ));
                                                        } else {
                                                          // return const Text("Follow");
                                                          return Obx(
                                                            () => tappedFollowIcons2
                                                                    .contains(
                                                                        user.id)
                                                                ? Container(
                                                                    height:
                                                                        75.h,
                                                                    width:
                                                                        279.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100.w),
                                                                      color: Color(
                                                                          0xFFFFB37C),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Pending",
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 32.sp,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                    ))
                                                                : Container(
                                                                    height:
                                                                        75.h,
                                                                    width:
                                                                        279.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100.w),
                                                                      color: Color(
                                                                          0xFFD5F600),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Follow",
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 32.sp,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                    )),
                                                          );
                                                        }
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // You can add more details or actions here
                            );
                          },
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
