// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
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

  viewPost(String userId, int postIndex, BuildContext context) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final name = userDoc.data()!['name'];
    final profilePhoto = userDoc.data()!['profile_photo'];

    showModalBottomSheet(
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
                          topLeft: Radius.circular(110.w),
                          topRight: Radius.circular(110.w)),
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 30.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Text("Khé",
                        style: CustomTexts.font14
                            .copyWith(color: CustomColors.textColor2)),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 30.w, top: 30.w),
                    child: SizedBox(
                      width: 180.w,
                      child: TextField(
                        maxLength: 20,
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                            hintText: "Enter Description",
                            hintStyle: CustomTexts.font14
                                .copyWith(color: CustomColors.textColor2)),
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
                              vertical: 10.h, horizontal: 20.w),
                          child: Center(
                              child: isModalSheetLoading.value
                                  ? CircularProgressIndicator()
                                  : Text(
                                      "Post",
                                      style: CustomTexts.font14,
                                    )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(26.w),
                  child: SizedBox(
                      height: 250.h,
                      width: double.infinity,
                      child: Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.fill,
                      ))),
            ],
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h, left: 20.w),
          child: ZoomTapAnimation(
            onTap: () async {
              isUploadPostLoading.value = true;
              _pickImage();
              isUploadPostLoading.value = false;
            },
            child: Obx(
              () => Container(
                height: 50.w,
                width: 100.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.w),
                    color: CustomColors.textColor2),
                child: Center(
                  child: isUploadPostLoading.value
                      ? SizedBox(
                          height: 16.sp,
                          width: 16.sp,
                          child: CircularProgressIndicator())
                      : Text(
                          "Upload Post",
                          style: CustomTexts.font12
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Text(
                "APP LOGO",
                style: CustomTexts.font16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CustomColors.backgroundColor,
                ),
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
                                (documents1[i]['has_posted'])
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(38.w),
                                    child: SizedBox(
                                      height: 100.sp,
                                      width: 100.sp,
                                      child: documents1[i]['profile_photo'] ==
                                              ""
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: CustomColors
                                                    .backgroundColor,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 64.sp,
                                                color: CustomColors.textColor,
                                              ),
                                            )
                                          : CachedNetworkImage(
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
                                              imageUrl: documents1[i]
                                                  ['profile_photo'],
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(documents1[i].id)
                                          .collection('Posts')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return CircularProgressIndicator();
                                        }
                                        final documents2 = snapshot.data!.docs;
                                        return Column(
                                          children: [
                                            for (int j = 0;
                                                j < documents2.length;
                                                j++) ...[
                                              documents2[j].id != "init"
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.h),
                                                      child: ZoomTapAnimation(
                                                        onTap: () async {
                                                          await viewPost(
                                                              documents1[i].id,
                                                              j,
                                                              context);
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      200.w),
                                                          child: SizedBox(
                                                            height: 60.sp,
                                                            width: 60.sp,
                                                            child:
                                                                CachedNetworkImage(
                                                              placeholder:
                                                                  (context,
                                                                      val) {
                                                                return SizedBox(
                                                                  width: 31.w,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Loading",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            15.sp,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              imageUrl: documents2[
                                                                      j][
                                                                  'post_photo'],
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ]
                                          ],
                                        );
                                      })
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 30.h,
                        ),
                        documents1[i]['has_posted'] &&
                                documents1[i].id !=
                                    FirebaseAuth.instance.currentUser!.uid
                            ? Container(
                                decoration:
                                    BoxDecoration(color: Colors.grey[400]),
                                height: 2.sp,
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
