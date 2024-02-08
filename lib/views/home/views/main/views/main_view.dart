// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MainView extends StatefulWidget {
  MainView({super.key});

  @override
  State<MainView> createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  RxBool isFollowButtonLoading = false.obs;
  RxBool isLiked = false.obs;
  RxBool isAddCommentLoading = false.obs;
  Widget checkUrl(String url) {
    try {
      return Image.network(url, height: 70.0, width: 70.0, fit: BoxFit.cover);
    } catch (e) {
      return Icon(Icons.image);
    }
  }

  final controller = Get.put(MainController());
  final storage = GetStorage();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  RxBool isUploadPostLoading = false.obs;
  RxBool isModalSheetLoading = false.obs;
  XFile? _imageFile; // Stores the picked image file

  Future<void> removeUserIdFromPostLikes(String userId, String postId) async {
    try {
      String currentUserId = await FirebaseAuth.instance.currentUser!.uid;
      // Reference to the user's post document
      DocumentReference postReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Posts')
          .doc(postId);

      // Get the current data of the post document
      DocumentSnapshot postSnapshot = await postReference.get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>? ?? {};

      // Get the current 'likes' array or initialize it if it doesn't exist
      List<dynamic> likes = postData['likes'] ?? [];

      // Remove the user ID from the 'likes' array if it exists
      if (likes.contains(currentUserId)) {
        likes.remove(currentUserId);

        // Update the post document with the modified 'likes' array
        await postReference.update({'likes': likes});

        print('Successfully removed $currentUserId from likes of post $postId');
      } else {
        print('$currentUserId is not in the likes of post $postId');
      }
    } catch (e) {
      print('Error removing like: $e');
    }
  }

  Future<bool> isUserIdInPostLikes(String userId, String postId) async {
    try {
      String currentUserId = await FirebaseAuth.instance.currentUser!.uid;
      DocumentReference postReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Posts')
          .doc(postId);
      DocumentSnapshot postSnapshot = await postReference.get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> likes = postData['likes'] ?? [];

      return likes.contains(currentUserId);
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  Widget buildCommentsStreamBuilder(String userId, int postIndex) {
    return StreamBuilder<QuerySnapshot>(
      // Change to QuerySnapshot
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Posts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading comments');
        }

        if (snapshot.hasData) {
          QuerySnapshot postsSnapshot = snapshot.data as QuerySnapshot;
          if (postsSnapshot.docs.length > postIndex) {
            // Ensure index is valid
            DocumentSnapshot postDoc = postsSnapshot.docs[postIndex];
            List<dynamic> comments = postDoc['comments'];

            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 30.h),
                  decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(60.w)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 60.w, vertical: 30.h),
                    child: Center(
                        child: Text(
                      comments[index],
                      style: GoogleFonts.poppins(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    )),
                  ),
                ); // Replace with your comment widget
              },
            );
          } else {
            return Text('Post not found'); // Handle invalid index
          }
        }

        return CircularProgressIndicator();
      },
    );
  }

  Future<void> addUserIdToPostLikes(String userId, String postId) async {
    try {
      String currentUserId = await FirebaseAuth.instance.currentUser!.uid;

      DocumentReference postReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Posts')
          .doc(postId);

      DocumentSnapshot postSnapshot = await postReference.get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> likes = postData['likes'] ?? [];
      if (!likes.contains(currentUserId)) {
        likes.add(currentUserId);
        await postReference.update({'likes': likes});

        print('Successfully added $currentUserId to likes of post $postId');
      } else {
        print('$currentUserId is already in the likes of post $postId');
      }
    } catch (e) {
      print('Error adding like: $e');
    }
  }

  Future<void> addCommentToPost(
      String userId, int postIndex, String comment) async {
    try {
      // Get the Posts collection reference
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Posts')
          .get();

      // Access the document at the specified index
      DocumentSnapshot postDoc = postsSnapshot.docs[postIndex];

      // Update the comments field of the document
      await postDoc.reference.update({
        'comments': FieldValue.arrayUnion([comment])
      });
    } catch (error) {
      // Handle errors as before
    }
  }

  commentModalSheet(String userId, int postIndex, BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color(0xFF101010),
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 1200.h),
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(top: 60.h, left: 60.w, right: 60.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      width: 600.w,
                      child: TextField(
                        style: GoogleFonts.poppins(
                            fontSize: 34.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          hoverColor: Colors.white,
                          fillColor: Colors.white,
                        ),
                        controller: commentController,
                      ),
                    ),
                    ZoomTapAnimation(
                      onTap: () async {
                        if (isAddCommentLoading.value) {
                        } else {
                          isAddCommentLoading.value = true;
                          await addCommentToPost(
                              userId, postIndex, commentController.text);
                          commentController.clear();
                          isAddCommentLoading.value = false;
                        }
                      },
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60.w),
                            color: Color(0xFFD5F600),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60.w, vertical: 30.h),
                            child: isAddCommentLoading.value
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Add Comment",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 34.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: 800.h,
                    child: buildCommentsStreamBuilder(userId, postIndex)),
              ],
            ),
          );
        });
  }

  viewPost(String userId, int postIndex, BuildContext context) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final name = userDoc.data()!['name'];
    final profilePhoto = userDoc.data()!['profile_photo'];

    showModalBottomSheet(
        constraints: BoxConstraints(maxHeight: 1937.h),
        isScrollControlled: true,
        backgroundColor: Colors.grey[400],
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .collection('Posts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final documents = snapshot.data!.docs;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80.w),
                          topRight: Radius.circular(80.w)),
                      child: SizedBox(
                        height: 1937.h,
                        width: 1.sw,
                        child: CachedNetworkImage(
                          placeholder: (context, val) {
                            return SizedBox(
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
                          imageUrl: documents[postIndex]['post_photo'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(top: 28.h),
                        height: 25.h,
                        width: 419.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.w),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 233.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 68.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 90.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF5F5F5)),
                                ),
                                SizedBox(
                                  height: 43.h,
                                ),
                                Container(
                                  width: 636.w,
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(200.w),
                                      color: Color(0xFF9EA2A3)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60.w,
                                      ),

                                      // SizedBox(
                                      //     width: 348.w,
                                      //     child: TextField(
                                      //       decoration: InputDecoration(
                                      //           border: InputBorder.none,
                                      //           hintText:
                                      //           hintStyle: GoogleFonts.poppins(
                                      //               fontSize: 64.sp,
                                      //               fontWeight: FontWeight.w600,
                                      //               color: Color(0xFFD5F600))),
                                      //       style: GoogleFonts.poppins(
                                      //           fontSize: 64.sp,
                                      //           fontWeight: FontWeight.w600,
                                      //           color: Color(0xFFD5F600)),
                                      //     )),
                                      SizedBox(
                                        width: 348.w,
                                        child: Text(
                                          documents[postIndex]['description'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 48.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD5F600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 68.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ZoomTapAnimation(
                                  onTap: () async {
                                    isFollowButtonLoading.value = true;
                                    await controller.isUserIdInFollowers(
                                      userId,
                                    )
                                        ? await controller
                                            .removeUserIdFromFollowers(userId)
                                        : await controller
                                            .addUserIdToFollowers(userId);
                                    isFollowButtonLoading.value = false;
                                  },
                                  child: Obx(
                                    () => Container(
                                      height: 150.sp,
                                      width: 150.sp,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF9EA2A3),
                                      ),
                                      child: Center(
                                        child: isFollowButtonLoading.value
                                            ? SizedBox(
                                                height: 40.h,
                                                width: 20.h,
                                                child:
                                                    const CircularProgressIndicator())
                                            : StreamBuilder(
                                                stream: controller
                                                    .isUserIdInFollowers(userId)
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
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20.sp),
                                                    );
                                                  } else {
                                                    // return const Text("Follow");
                                                    return Center(
                                                      child: Image.asset(
                                                        "assets/images/png/follow_icon.png",
                                                        height: 70.sp,
                                                        width: 70.sp,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 66.h,
                                ),
                                ZoomTapAnimation(
                                  onTap: () async {
                                    // await isUserIdInPostLikes(
                                    //         userId, documents[postIndex].id)
                                    //     ? await removeUserIdFromPostLikes(
                                    //         userId, documents[postIndex].id)
                                    //     : await addUserIdToPostLikes(
                                    //         userId, documents[postIndex].id);
                                    if (await isUserIdInPostLikes(
                                        userId, documents[postIndex].id)) {
                                      await removeUserIdFromPostLikes(
                                          userId, documents[postIndex].id);
                                    } else {
                                      await addUserIdToPostLikes(
                                          userId, documents[postIndex].id);
                                    }
                                  },
                                  child: Container(
                                    height: 150.sp,
                                    width: 150.sp,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF9EA2A3),
                                    ),
                                    child: Center(
                                      child: Icon(CupertinoIcons.heart_fill,
                                          size: 90.sp,
                                          color: Color(0xFFD5F600)),
                                    ),
                                  ),
                                ),
                                Text(
                                  (documents[postIndex]['likes'].length)
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 40.sp, color: Colors.white),
                                ),
                                SizedBox(
                                  height: 66.h,
                                ),
                                ZoomTapAnimation(
                                  onTap: () {
                                    //commentModalSheet
                                    commentModalSheet(
                                        userId, postIndex, context);
                                  },
                                  child: Container(
                                    height: 150.sp,
                                    width: 150.sp,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF9EA2A3),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/images/png/comment_icon.png",
                                        height: 80.sp,
                                        width: 80.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding: EdgeInsets.only(left: 30.w),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Row(
                //                 children: [
                //                   ClipRRect(
                //                     borderRadius: BorderRadius.circular(16.w),
                //                     child: SizedBox(
                //                       height: 30.sp,
                //                       width: 30.sp,
                //                       child: (profilePhoto != "")
                //                           ? CachedNetworkImage(
                //                               placeholder: (context, val) {
                //                                 return Container(
                //                                   width: 31.w,
                //                                   child: Center(
                //                                     child: Text(
                //                                       "Loading",
                //                                       style: TextStyle(
                //                                         fontWeight:
                //                                             FontWeight.bold,
                //                                         fontSize: 15.sp,
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 );
                //                               },
                //                               imageUrl: profilePhoto,
                //                               fit: BoxFit.fill,
                //                             )
                //                           : Container(
                //                               decoration: BoxDecoration(
                //                                   color: CustomColors
                //                                       .backgroundColor),
                //                               child: Icon(
                //                                 Icons.person,
                //                                 color: CustomColors.textColor,
                //                               )),
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.only(left: 18.w),
                //                     child: Text(
                //                       name,
                //                       style: CustomTexts.font24.copyWith(
                //                           color: CustomColors.textColor2,
                //                           fontWeight: FontWeight.bold),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //               StreamBuilder<QuerySnapshot>(
                //                 stream: FirebaseFirestore.instance
                //                     .collection('Users')
                //                     .snapshots(),
                //                 builder: (context, snapshot) {
                //                   if (snapshot.hasData) {
                //                     for (final doc in snapshot.data!.docs) {
                //                       if (doc.id == userId) {
                //                         final follower = doc
                //                             .get('followers')
                //                             .length;
                //                         return Text(
                //                           '$follower Followers',
                //                           style: CustomTexts.font14.copyWith(
                //                               color: CustomColors.textColor2),
                //                         );
                //                       }
                //                     }
                //                   }
                //                   return const SizedBox();
                //                 },
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10.h,
                //         ),
                //         Padding(
                //           padding: EdgeInsets.only(left: 20.w),
                //           child: Align(
                //             alignment: Alignment.bottomLeft,
                //             child: SizedBox(
                //               height: 200.h,
                //               width: 200.w,
                //               child: ClipRRect(
                //                 borderRadius: BorderRadius.circular(38.w),
                //                 child: SizedBox(
                //                   height: 200.h,
                //                   width: 200.w,
                //                   child: CachedNetworkImage(
                //                     placeholder: (context, val) {
                //                       return SizedBox(
                //                         width: 31.w,
                //                         child: Center(
                //                           child: Text(
                //                             "Loading",
                //                             style: TextStyle(
                //                               fontWeight: FontWeight.bold,
                //                               fontSize: 15.sp,
                //                             ),
                //                           ),
                //                         ),
                //                       );
                //                     },
                //                     imageUrl: documents[postIndex]
                //                         ['post_photo'],
                //                     fit: BoxFit.fill,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.h,
                //         ),
                //         Padding(
                //           padding: EdgeInsets.only(left: 30.w),
                //           child: Text(
                //             documents[postIndex]['description'],
                //             style: CustomTexts.font14.copyWith(
                //                 color: CustomColors.backgroundColor),
                //           ),
                //         ),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         SizedBox(
                //           height: 40.h,
                //         ),
                //         ZoomTapAnimation(
                //           onTap: () async {
                //             await isUserIdInPostLikes(
                //                     userId, documents[postIndex].id)
                //                 ? await removeUserIdFromPostLikes(
                //                     userId, documents[postIndex].id)
                //                 : await addUserIdToPostLikes(
                //                     userId, documents[postIndex].id);
                //           },
                //           child: Icon(
                //             CupertinoIcons.heart_fill,
                //             size: 48.sp,
                //             color: CustomColors.activeColor,
                //           ),
                //         ),
                //         SizedBox(
                //           height: 8.h,
                //         ),
                //         Text(
                //           (documents[postIndex]['likes'].length).toString(),
                //           style: CustomTexts.font18
                //               .copyWith(color: CustomColors.inactiveColor),
                //         ),
                //         SizedBox(
                //           height: 10.h,
                //         ),
                //         ZoomTapAnimation(
                //           onTap: () async {
                //             isFollowButtonLoading.value = true;
                //             await controller.isUserIdInFollowers(
                //               userId,
                //             )
                //                 ? await controller
                //                     .removeUserIdFromFollowers(userId)
                //                 : await controller
                //                     .addUserIdToFollowers(userId);
                //             isFollowButtonLoading.value = false;
                //           },
                //           child: Obx(
                //             () => Container(
                //               width: 110.w,
                //               height: 40.h,
                //               decoration: BoxDecoration(
                //                   color: CustomColors.activeColor,
                //                   borderRadius: BorderRadius.circular(12.w)),
                //               child: Padding(
                //                 padding: EdgeInsets.symmetric(
                //                     vertical: 10.h, horizontal: 20.w),
                //                 child: Center(
                //                     child: isFollowButtonLoading.value
                //                         ? SizedBox(
                //                             height: 40.h,
                //                             width: 20.h,
                //                             child:
                //                                 const CircularProgressIndicator())
                //                         : StreamBuilder(
                //                             stream: controller
                //                                 .isUserIdInFollowers(userId)
                //                                 .asStream(),
                //                             builder: (context, snapshot) {
                //                               if (!snapshot.hasData) {
                //                                 return SizedBox(
                //                                     height: 40.h,
                //                                     width: 20.h,
                //                                     child:
                //                                         const CircularProgressIndicator());
                //                               }

                //                               if (snapshot.data!) {
                //                                 return const Text("Unfollow");
                //                               } else {
                //                                 return const Text("Follow");
                //                               }
                //                             })
                //                     ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // );
              });
        });
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      showModalBottomSheet(
        backgroundColor: Colors.grey[400],
        context: context,
        builder: (context) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80.w),
                    topRight: Radius.circular(80.w)),
                child: SizedBox(
                    height: 1937.h,
                    width: 1.sw,
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.fill,
                    )),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 28.h),
                  height: 25.h,
                  width: 419.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.w),
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Text("Khé",
                            style: GoogleFonts.poppins(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD5F600))),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 30.w, top: 60.w),
                        child: SizedBox(
                          width: 700.w,
                          child: TextField(
                            style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD5F600)),
                            maxLength: 20,
                            controller: descriptionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                                hintText: "Enter Description",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 48.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD5F600))),
                          ),
                        ),
                      ),
                      ZoomTapAnimation(
                        onTap: () async {
                          isModalSheetLoading.value = true;
                          await controller.uploadPost(
                              pickedFile, "Khé " + descriptionController.text);
                          isModalSheetLoading.value = false;
                          Navigator.pop(context);
                        },
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                                color: CustomColors.activeColor,
                                borderRadius: BorderRadius.circular(12.w)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 60.w),
                              child: Center(
                                  child: isModalSheetLoading.value
                                      ? CircularProgressIndicator()
                                      : Text(
                                          "Post",
                                          style: GoogleFonts.poppins(
                                              fontSize: 48.sp,
                                              color: Colors.white),
                                        )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
          // return Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         SizedBox(
          //           width: 30.w,
          //         ),
          //         Padding(
          //           padding: EdgeInsets.only(bottom: 10.h),
          //           child: Text("Khé",
          //               style: CustomTexts.font14
          //                   .copyWith(color: CustomColors.textColor2)),
          //         ),
          //         SizedBox(
          //           width: 10.w,
          //         ),
          //         Padding(
          //           padding: EdgeInsets.only(right: 30.w, top: 30.w),
          //           child: SizedBox(
          //             width: 180.w,
          //             child: TextField(
          //               maxLength: 20,
          //               controller: descriptionController,
          //               maxLines: 2,
          //               decoration: InputDecoration(
          //                   hintText: "Enter Description",
          //                   hintStyle: CustomTexts.font14
          //                       .copyWith(color: CustomColors.textColor2)),
          //             ),
          //           ),
          //         ),
          //         ZoomTapAnimation(
          //           onTap: () async {
          //             isModalSheetLoading.value = true;
          //             await controller.uploadPost(
          //                 pickedFile, "Khé " + descriptionController.text);
          //             isModalSheetLoading.value = false;
          //             Navigator.pop(context);
          //           },
          //           child: Obx(
          //             () => Container(
          //               decoration: BoxDecoration(
          //                   color: CustomColors.activeColor,
          //                   borderRadius: BorderRadius.circular(12.w)),
          //               child: Padding(
          //                 padding: EdgeInsets.symmetric(
          //                     vertical: 10.h, horizontal: 20.w),
          //                 child: Center(
          //                     child: isModalSheetLoading.value
          //                         ? CircularProgressIndicator()
          //                         : Text(
          //                             "Post",
          //                             style: CustomTexts.font14,
          //                           )),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //     ClipRRect(
          //         borderRadius: BorderRadius.circular(26.w),
          //         child: SizedBox(
          //             height: 250.h,
          //             width: double.infinity,
          //             child: Image.file(
          //               File(_imageFile!.path),
          //               fit: BoxFit.fill,
          //             ))),
          //   ],
          // );
        },
      );
    }
  }

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');
  bool checkIfNameFieldExists(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('description')) {
      // 'name' field exists in the document
      return true;
    } else {
      // 'name' field does not exist in the document
      return false;
    }
  }

  final usersRef = FirebaseFirestore.instance.collection('Users');
  List<double> leftPosition = [65.0, 450.0, 800.0, 600.0, 242.0];
  List<double> bottomPosition = [444.0, 753.0, 444.0, 80.0, 80.0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 20.w),
        child: ZoomTapAnimation(
          onTap: () async {
            isUploadPostLoading.value = true;
            _pickImage();
            isUploadPostLoading.value = false;
          },
          child: Obx(
            () => Container(
              height: 150.sp,
              width: 150.sp,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD5F600)),
              child: Center(
                child: isUploadPostLoading.value
                    ? SizedBox(
                        height: 50.sp,
                        width: 50.sp,
                        child: const CircularProgressIndicator())
                    : Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0XFF101010),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              SizedBox(
                height: 40.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 65.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                    ),
                    Image.asset(
                      "assets/images/png/intro_logo.png",
                      height: 90.h,
                      width: 219.w,
                    ),
                    ZoomTapAnimation(
                      onTap: () {
                        Get.put(HomeController())
                            .bottomNavController
                            .jumpToTab(3);
                      },
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 74.h,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: userCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final documents1 = snapshot.data!.docs;
                  return Column(
                    children: [
                      for (int i = 0; i < documents1.length; i++) ...[
                        (documents1[i].id !=
                                    FirebaseAuth.instance.currentUser!.uid) &&
                                (documents1[i]['has_posted'] &&
                                    (documents1[i]['followers'].contains(
                                        FirebaseAuth
                                            .instance.currentUser!.uid)))
                            ? SizedBox(
                                height: 1000.h,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(200.w),
                                              child: SizedBox(
                                                height: 365.sp,
                                                width: 365.sp,
                                                child: documents1[i]
                                                            ['profile_photo'] ==
                                                        ""
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: CustomColors
                                                              .backgroundColor,
                                                        ),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 64.sp,
                                                          color: CustomColors
                                                              .textColor,
                                                        ),
                                                      )
                                                    : CachedNetworkImage(
                                                        placeholder:
                                                            (context, val) {
                                                          return Container(
                                                            width: 31.w,
                                                            child: Center(
                                                              child: Text(
                                                                "Loading",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      15.sp,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        imageUrl: documents1[i]
                                                            ['profile_photo'],
                                                        fit: BoxFit.fill,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Image.asset(
                                              "assets/images/png/profile_photo_border.png",
                                              height: 420.sp,
                                              width: 420.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //it was center photo

                                    SizedBox(
                                      height: 980.h,
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(documents1[i].id)
                                              .collection('Posts')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return CircularProgressIndicator();
                                            }
                                            final documents2 =
                                                snapshot.data!.docs;
                                            return Stack(
                                              children: [
                                                Center(
                                                  child: Image.asset(
                                                    "assets/images/png/post_photo_border.png",
                                                    height: 803.sp,
                                                    width: 803.sp,
                                                  ),
                                                ),
                                                Stack(
                                                  children: [
                                                    for (int j = 0;
                                                        j < documents2.length;
                                                        j++) ...[
                                                      // documents2[j].id != 'init'
                                                      //     ?
                                                      Positioned(
                                                        left: leftPosition[j].w,
                                                        bottom:
                                                            bottomPosition[j].h,
                                                        child: documents2[j]
                                                                    .id ==
                                                                'init'
                                                            ? SizedBox()
                                                            : ZoomTapAnimation(
                                                                onTap:
                                                                    () async {
                                                                  await viewPost(
                                                                      documents1[
                                                                              i]
                                                                          .id,
                                                                      j,
                                                                      context);
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              200.w),
                                                                  child:
                                                                      SizedBox(
                                                                    height:
                                                                        220.sp,
                                                                    width:
                                                                        220.sp,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      placeholder:
                                                                          (context,
                                                                              val) {
                                                                        return SizedBox(
                                                                          width:
                                                                              31.w,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "Loading",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      imageUrl:
                                                                          documents2[j]
                                                                              [
                                                                              'post_photo'],
                                                                      fit: BoxFit
                                                                          .fill,
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
                                              ],
                                            );
                                          }),
                                    ),
                                    // return Column(
                                    //   children: [
                                    //     for (int j = 0;
                                    //         j < documents2.length;
                                    //         j++) ...[
                                    //       documents2[j].id != "init"
                                    //           ? ZoomTapAnimation(
                                    //             onTap: () async {
                                    //               await viewPost(
                                    //                   documents1[i].id,
                                    //                   j,
                                    //                   context);
                                    //             },
                                    //             child: ClipRRect(
                                    //               borderRadius:
                                    //                   BorderRadius
                                    //                       .circular(
                                    //                           200.w),
                                    //               child: SizedBox(
                                    //                 height: 220.sp,
                                    //                 width: 220.sp,
                                    //                 child:
                                    //                     CachedNetworkImage(
                                    //                   placeholder:
                                    //                       (context,
                                    //                           val) {
                                    //                     return SizedBox(
                                    //                       width: 31.w,
                                    //                       child: Center(
                                    //                         child: Text(
                                    //                           "Loading",
                                    //                           style:
                                    //                               TextStyle(
                                    //                             fontWeight:
                                    //                                 FontWeight.bold,
                                    //                             fontSize:
                                    //                                 15.sp,
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     );
                                    //                   },
                                    //                   imageUrl: documents2[
                                    //                           j][
                                    //                       'post_photo'],
                                    //                   fit: BoxFit.fill,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           )
                                    //           : const SizedBox(),

                                    // Positioned(
                                    //     left: 65.w,
                                    //     bottom: 444.h,
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         color: Colors.red,
                                    //       ),
                                    //       height: 220.sp,
                                    //       width: 220.sp,
                                    //     )),
                                    // Positioned(
                                    //     left: 450.w,
                                    //     bottom: 753.h,
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         color: Colors.blue,
                                    //       ),
                                    //       height: 220.sp,
                                    //       width: 220.sp,
                                    //     )),
                                    // Positioned(
                                    //     left: 800.w,
                                    //     bottom: 444.h,
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         color: Colors.green,
                                    //       ),
                                    //       height: 220.sp,
                                    //       width: 220.sp,
                                    //     )),
                                    // Positioned(
                                    //     left: 600.w,
                                    //     bottom: 80.h,
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         color: Colors.white,
                                    //       ),
                                    //       height: 220.sp,
                                    //       width: 220.sp,
                                    //     )),
                                    // Positioned(
                                    //     left: 242.w,
                                    //     bottom: 80.h,
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         color: Colors.white,
                                    //       ),
                                    //       height: 220.sp,
                                    //       width: 220.sp,
                                    //     )),
                                  ],
                                ),
                              )
                            // Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceEvenly,
                            //     children: [
                            //       ClipRRect(
                            //         borderRadius: BorderRadius.circular(38.w),
                            //         child: SizedBox(
                            //           height: 100.sp,
                            //           width: 100.sp,
                            //           child: documents1[i]['profile_photo'] ==
                            //                   ""
                            //               ? Container(
                            //                   decoration: BoxDecoration(
                            //                     color: CustomColors
                            //                         .backgroundColor,
                            //                   ),
                            //                   child: Icon(
                            //                     Icons.person,
                            //                     size: 64.sp,
                            //                     color: CustomColors.textColor,
                            //                   ),
                            //                 )
                            //               : CachedNetworkImage(
                            //                   placeholder: (context, val) {
                            //                     return Container(
                            //                       width: 31.w,
                            //                       child: Center(
                            //                         child: Text(
                            //                           "Loading",
                            //                           style: TextStyle(
                            //                             fontWeight:
                            //                                 FontWeight.bold,
                            //                             fontSize: 15.sp,
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     );
                            //                   },
                            //                   imageUrl: documents1[i]
                            //                       ['profile_photo'],
                            //                   fit: BoxFit.fill,
                            //                 ),
                            //         ),
                            //       ),
                            //       StreamBuilder(
                            //           stream: FirebaseFirestore.instance
                            //               .collection('Users')
                            //               .doc(documents1[i].id)
                            //               .collection('Posts')
                            //               .snapshots(),
                            //           builder: (context, snapshot) {
                            //             if (!snapshot.hasData) {
                            //               return CircularProgressIndicator();
                            //             }
                            //             final documents2 = snapshot.data!.docs;
                            //             return Column(
                            //               children: [
                            //                 for (int j = 0;
                            //                     j < documents2.length;
                            //                     j++) ...[
                            //                   documents2[j].id != "init"
                            //                       ? Padding(
                            //                           padding:
                            //                               EdgeInsets.symmetric(
                            //                                   vertical: 5.h),
                            //                           child: ZoomTapAnimation(
                            //                             onTap: () async {
                            //                               await viewPost(
                            //                                   documents1[i].id,
                            //                                   j,
                            //                                   context);
                            //                             },
                            //                             child: ClipRRect(
                            //                               borderRadius:
                            //                                   BorderRadius
                            //                                       .circular(
                            //                                           200.w),
                            //                               child: SizedBox(
                            //                                 height: 60.sp,
                            //                                 width: 60.sp,
                            //                                 child:
                            //                                     CachedNetworkImage(
                            //                                   placeholder:
                            //                                       (context,
                            //                                           val) {
                            //                                     return SizedBox(
                            //                                       width: 31.w,
                            //                                       child: Center(
                            //                                         child: Text(
                            //                                           "Loading",
                            //                                           style:
                            //                                               TextStyle(
                            //                                             fontWeight:
                            //                                                 FontWeight.bold,
                            //                                             fontSize:
                            //                                                 15.sp,
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                     );
                            //                                   },
                            //                                   imageUrl: documents2[
                            //                                           j][
                            //                                       'post_photo'],
                            //                                   fit: BoxFit.fill,
                            //                                 ),
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         )
                            //                       : const SizedBox(),
                            //                 ]
                            //               ],
                            //             );
                            //           })
                            //     ],
                            //   )
                            : SizedBox(),
                        SizedBox(
                          height: 30.h,
                        ),
                        documents1[i]['has_posted'] &&
                                documents1[i].id !=
                                    FirebaseAuth.instance.currentUser!.uid &&
                                (documents1[i]['followers'].contains(
                                    FirebaseAuth.instance.currentUser!.uid))
                            ? Center(
                                child: Container(
                                  decoration:
                                      BoxDecoration(color: Color(0xFFD9D9D9)),
                                  height: 2.sp,
                                  width: 350.w,
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 30.h,
                        ),
                      ]
                    ],
                  );
                },
              )
            ],
          ),
        ),
      )),
    );
  }
}

class ProfileAndPostPhoto extends StatelessWidget {
  final DocumentSnapshot user;
  ProfileAndPostPhoto({required this.user});

  // const ProfileAndPostPhoto({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: user.reference.collection('Posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final posts = snapshot.data!.docs;
          return Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  user['profile_photo'],
                ),
                radius: 80,
              ),
              ...posts.map((post) {
                if (post.id != 'init') {
                  return ClipOval(
                    child: Transform.rotate(
                      angle: posts.indexOf(post) * 2 * 3.14 / posts.length,
                      child: CachedNetworkImage(
                        imageUrl: post['post_photo'],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }).toList(),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
