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
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/home_view.dart';
import 'package:social_type/views/home/views/main/controllers/main_controller.dart';

import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:social_type/views/home/views/viral/controllers/viral_controller.dart';
import 'package:social_type/views/home/views/viral/views/search_view.dart';
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
  // Future<int> getTotalPostsCount() async {
  //   try {
  //     // Reference to the 'Users' collection
  //     CollectionReference usersCollection =
  //         FirebaseFirestore.instance.collection('Users');

  //     // QuerySnapshot to get all documents in the 'Users' collection
  //     QuerySnapshot usersSnapshot = await usersCollection.get();

  //     int totalPostsCount = 0;

  //     // Iterate through each document in the 'Users' collection
  //     for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
  //       // Get the reference to the 'Posts' collection for each user
  //       CollectionReference postsCollection =
  //           userDoc.reference.collection('Posts');

  //       // QuerySnapshot to get all documents in the 'Posts' collection for the current user
  //       QuerySnapshot postsSnapshot = await postsCollection.get();

  //       // Increment the total count with the number of documents in the 'Posts' collection for the current user
  //       totalPostsCount += postsSnapshot.size;
  //     }

  //     // Return the total count of documents in the 'Posts' collection across all users
  //     return totalPostsCount - 1;
  //   } catch (e) {
  //     print('Error getting total posts count: $e');
  //     return 0; // Return 0 if there's an error
  //   }
  // }
//   int totalPosts = 0;
  Future<int> getNumberOfPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('error 1 '); // Handle or throw an error if no user is signed in
    }

    final uid = user!.uid;

    try {
      int totalPosts = 0;
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Posts')
          .get();
      totalPosts = snapshot.size - 1;
      return totalPosts;
    } on FirebaseException catch (e) {
      // Handle errors gracefully, e.g., log, display user-friendly message
      print('Error getting number of posts: $e');
      return 9;
// Indicate an error occurred
    }
  }

  Future<void> removeUserIdFromPostLikes(String? userId, String postId) async {
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

  Future<bool> isUserIdInPostLikes(String? userId, String postId) async {
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

  Widget buildCommentsStreamBuilder(String? userId, int postIndex) {
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

  Future<void> addUserIdToPostLikes(String? userId, String postId) async {
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
      String? userId, int postIndex, String comment) async {
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

  commentModalSheet(String? userId, int postIndex, BuildContext context) {
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

  viewPost(String? userId, int postIndex, BuildContext context) async {
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
                                Opacity(
                                  opacity: 0.6,
                                  child: Container(
                                    width: 636.w,
                                    height: 200.h,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(200.w),
                                      color: Color(0xFF9EA2A3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        documents[postIndex]['description'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 72.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFD5F600)),
                                      ),
                                    ),
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
                                FirebaseAuth.instance.currentUser!.uid == userId
                                    ? SizedBox()
                                    : ZoomTapAnimation(
                                        onTap: () async {
                                          isFollowButtonLoading.value = true;
                                          await controller.isUserIdInFollowers(
                                            userId,
                                          )
                                              ? await controller
                                                  .removeUserIdFromFollowers(
                                                      userId)
                                              : await controller
                                                  .addUserIdToFollowers(userId);
                                          isFollowButtonLoading.value = false;
                                        },
                                        child: Obx(
                                          () => Opacity(
                                            opacity: 0.6,
                                            child: Container(
                                              height: 150.sp,
                                              width: 150.sp,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF9EA2A3),
                                              ),
                                              child: Center(
                                                child: isFollowButtonLoading
                                                        .value
                                                    ? SizedBox(
                                                        height: 40.h,
                                                        width: 20.h,
                                                        child:
                                                            const CircularProgressIndicator())
                                                    : StreamBuilder(
                                                        stream: controller
                                                            .isUserIdInFollowers(
                                                                userId)
                                                            .asStream(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
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
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1),
                                                                  fontSize:
                                                                      20.sp),
                                                            );
                                                          } else {
                                                            // return const Text("Follow");
                                                            return Center(
                                                              child:
                                                                  Image.asset(
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
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Container(
                                      height: 150.sp,
                                      width: 150.sp,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF9EA2A3),
                                      ),
                                      child: StreamBuilder(
                                        stream: isUserIdInPostLikes(
                                                userId, documents[postIndex].id)
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
                                            return Center(
                                                child: Icon(
                                                    CupertinoIcons.heart_fill,
                                                    color: Color(0xFFD5F600),
                                                    size: 90.sp));
                                          } else {
                                            // return const Text("Follow");
                                            return Center(
                                                child: Icon(
                                                    CupertinoIcons.heart_fill,
                                                    color: Colors.white,
                                                    size: 90.sp));
                                          }
                                        },
                                      ),
                                      // child: Center(
                                      //   child: Icon(CupertinoIcons.heart_fill,
                                      //       size: 90.sp,
                                      //       color: Color(0xFFD5F600)),
                                      // ),
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
                                  child: Opacity(
                                    opacity: 0.6,
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
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
                            width: 650.w,
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
                            await controller.uploadPost(pickedFile,
                                "Khé " + descriptionController.text);
                            isModalSheetLoading.value = false;
                            Navigator.pop(context);
                          },
                          child: Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                  color: CustomColors.activeColor,
                                  borderRadius: BorderRadius.circular(12.w)),
                              child: SizedBox(
                                width: 250.w,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  Future<void> _refreshData() async {
    // Fetch new data, update state variables, etc.
    setState(() {
      // Update state variables here
    });
    await Future.delayed(Duration(seconds: 1));
  }

  final usersRef = FirebaseFirestore.instance.collection('Users');
  List<double> leftPosition = [65.0, 420.0, 800.0, 600.0, 242.0];
  List<double> bottomPosition = [444.0, 753.0, 444.0, 80.0, 80.0];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20.h, left: 20.w),
          child: ZoomTapAnimation(
            onTap: () async {
              if (isUploadPostLoading.value) {
              } else {
                isUploadPostLoading.value = true;
                (await getNumberOfPosts() < 5)
                    ? _pickImage()
                    : Get.defaultDialog(
                        title: "You already have 5 posts", middleText: "");
                isUploadPostLoading.value = false;
              }
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
                      ZoomTapAnimation(
                        onTap: () {
                          // Get.put(ViralController()).isSearchActive.value =
                          //     true;
                          // Get.put(HomeController()).clearBottomNav();
                          // Get.put(HomeController()).viralSelected.value = true;
                          // Get.put(HomeController())
                          //     .bottomNavController
                          //     .jumpToTab(1);
                          Get.to(SearchView());
                        },
                        child: const Icon(
                          Icons.search_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Image.asset(
                        "assets/images/png/intro_logo.png",
                        height: 90.h,
                        width: 219.w,
                      ),
                      ZoomTapAnimation(
                        onTap: () {
                          // Get.put(HomeController()).clearBottomNav();
                          // Get.put(HomeController()).profileSelected.value =
                          //     true;
                          // Get.put(HomeController())
                          //     .bottomNavController
                          //     .jumpToTab(3);
                          //
                          Get.put(HomeController()).index.value = 3;
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
                                      //align was here

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
                                                          j <
                                                              documents2
                                                                      .length -
                                                                  1;
                                                          j++) ...[
                                                        // documents2[j].id != 'init'
                                                        //     ?
                                                        Positioned(
                                                          left:
                                                              leftPosition[j].w,
                                                          bottom:
                                                              bottomPosition[j]
                                                                  .h,
                                                          child: documents2[j]
                                                                      .id ==
                                                                  'init'
                                                              ? SizedBox()
                                                              : ZoomTapAnimation(
                                                                  onTap:
                                                                      () async {
                                                                    await viewPost(
                                                                        documents1[i]
                                                                            .id,
                                                                        j,
                                                                        context);
                                                                  },
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            200.w),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          220.sp,
                                                                      width: 220
                                                                          .sp,
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
                                                                        imageUrl:
                                                                            documents2[j]['post_photo'],
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
                                                  //got pasted here
                                                  ZoomTapAnimation(
                                                    onTap: () async{
                                                      Get.to(() =>
                                                          // UserProfileView(
                                                          //   userUid:
                                                          //       documents1[i]
                                                          //           .id,
                                                          // )
                                                          ProfileView(
                                                              userUid:
                                                                  documents1[i]
                                                                      .id));

                                                   
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Stack(
                                                        children: [
                                                          Center(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200.w),
                                                              child: SizedBox(
                                                                height: 365.sp,
                                                                width: 365.sp,
                                                                child: documents1[i]
                                                                            [
                                                                            'profile_photo'] ==
                                                                        ""
                                                                    ? Stack(
                                                                        children: [
                                                                          Center(
                                                                            child:
                                                                                Container(
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
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Padding(
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
                                                                            child:
                                                                                SizedBox(
                                                                              height: 365.sp,
                                                                              width: 365.sp,
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
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Padding(
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
                                                              height: 420.sp,
                                                              width: 420.sp,
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
      ),
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
