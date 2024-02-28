import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/views/home/controllers/home_controller.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:social_type/views/home/views/viral/controllers/viral_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class Post {
  final String profilePhotoUrl;
  final String description;

  Post({
    required this.profilePhotoUrl,
    required this.description,
  });
}

class ViralView extends StatefulWidget {
  ViralView({super.key});

  @override
  State<ViralView> createState() => _ViralViewState();
}

class _ViralViewState extends State<ViralView> {
  final controller = Get.put(ViralController());
  List<ProfilePhotoData> profilePhotos = [];

  Future<List<ProfilePhotoData>>
      fetchAllprofilePhotos2SortedByDateTime() async {
    List<ProfilePhotoData> allprofilePhotos2 = [];

    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      // Iterate through each user document
      for (var userDoc in usersSnapshot.docs) {
        List<ProfilePhotoData> profilePhotos2 =
            await fetchprofilePhotos2SortedByDateTime(userDoc.id);
        allprofilePhotos2.addAll(profilePhotos2);
      }

      // Sort all profile photos by DateTime
      allprofilePhotos2
          .sort((a, b) => a.profilePhoto.compareTo(b.profilePhoto));

      return allprofilePhotos2;
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching all profile photos: $e');
      return [];
    }
  }

  Future<List<ProfilePhotoData>> fetchprofilePhotos2SortedByDateTime(
      String uid) async {
    List<ProfilePhotoData> profilePhotos2 = [];

    try {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Posts')
          .get();

      // Extracting and sorting the posts by DateTime value
      // List<DocumentSnapshot> sortedPosts = postsSnapshot.docs
      //     .where((doc) => doc.id != 'init')
      //     .toList()
      //   ..sort((a, b) => DateTime.parse(b.id).compareTo(DateTime.parse(a.id)));
      List<DocumentSnapshot> sortedPosts = postsSnapshot.docs
          .where((doc) => doc.id != 'init')
          .toList()
        ..sort((a, b) => DateTime.parse(b.id).compareTo(DateTime.parse(a.id)));

      // Iterate through each sorted post document
      for (var postSnapshot in sortedPosts) {
        // Access likes and profile photo
        final data = postSnapshot.data() as Map<String, dynamic>;
        List<dynamic>? likes = data['likes'];
        String? profilePhoto = data['post_photo'];

        // Add data to profilePhotos2 list
        if (profilePhoto != null && likes != null) {
          profilePhotos2.add(ProfilePhotoData(
            uid: uid,
            profilePhoto: profilePhoto,
            likes: likes.length,
          ));
        }
      }

      return profilePhotos2;
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching profile photos: $e');
      return [];
    }
  }

  bool showProgressIndicator = true;

  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  Future<int?> findProfilePhotoIndex(String uid, String profilePhoto) async {
    try {
      int index = 0;

      // Access the posts collection for the given UID
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Posts')
          .get();

      // Iterate through each post document
      for (var postSnapshot in postsSnapshot.docs) {
        // Ignore the 'init' document
        if (postSnapshot.id != 'init') {
          // Check if the profile photo matches
          String? pP =
              (postSnapshot.data() as Map<String, dynamic>?)?['post_photo'];
          // print(index);
          // print (pP);
          if (pP == profilePhoto) {
            return index;
          }
          index++;
        }
      }
      // If the profile photo is not found, return null
      return null;
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error finding profile photo index: $e');
      return null;
    }
  }

  Future<List<ProfilePhotoData>> fetchProfilePhotos() async {
    List<ProfilePhotoData> profilePhotos = [];

    QuerySnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    for (var userDoc in userSnapshot.docs) {
      if (userDoc['has_posted']) {
        QuerySnapshot postsSnapshot =
            await userDoc.reference.collection('Posts').get();
        for (var postSnapshot in postsSnapshot.docs) {
          if (postSnapshot.id != 'init') {
            final data = postSnapshot.data() as Map<String, dynamic>;
            final likes = data['likes'];
            final profilePhoto = data['post_photo'];
            final uid = userDoc.id;

            profilePhotos.add(ProfilePhotoData(
              uid: uid,
              profilePhoto: profilePhoto,
              likes: likes.length,
            ));
          }
        }
      }
    }

    profilePhotos.sort((a, b) => b.likes.compareTo(a.likes));
    return profilePhotos;
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      controller.isSearchActive.value = (searchController.text.isNotEmpty);
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showProgressIndicator = false;
      });
    });
  }

  void sortViralList(List<List<String>> viralList) {
    viralList.sort((a, b) {
      // Parse the DateTime strings
      final dateA = DateTime.parse(a[1]);
      final dateB = DateTime.parse(b[1]);

      // Compare the dates in descending order (latest first)
      return dateB.compareTo(dateA);
    });
  }

  List<String> descriptionList = [];
  Future<void> showAllDescriptions() async {
    // Get a reference to the Firestore collection
    final usersCollection = FirebaseFirestore.instance.collection('Users');

    // Stream all user documents
    final usersStream = usersCollection.snapshots();

    // Handle each user document
    await usersStream.forEach((QuerySnapshot snapshot) async {
      for (DocumentSnapshot userDoc in snapshot.docs) {
        final uid = userDoc.id; // Get the current user's UID

        // Get a reference to the user's posts collection
        final postsCollection = usersCollection.doc(uid).collection('Posts');

        // Stream all posts documents for the user
        final postsStream = postsCollection.snapshots();

        // Handle each post document
        await postsStream.forEach((QuerySnapshot snapshot) async {
          for (DocumentSnapshot postDoc in snapshot.docs) {
            final description = postDoc.get('description');
            descriptionList.add(description);
            // Display the description (replace this with your preferred way)
            print(description); // Log to console
            // TODO: Show description in UI (e.g., using ListView, Text widget)
          }
        });
      }
    });
  }

  Future<void> _refreshData() async {
    // Fetch new data, update state variables, etc.
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          Get.put(HomeController()).index.value = 0;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Image.asset(
                  "assets/images/png/onboarding_khe.png",
                  color: Colors.white,
                  width: 219.w,
                  height: 90.h,
                ),
              ),
              backgroundColor: const Color(0XFF101010),
              bottom: TabBar(
                  dividerColor: Color(0xFF101010),
                  indicatorColor: Color(0xFF101010),
                  tabs: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/png/bottom_nav_viral.png',
                            height: 60.sp,
                            width: 60.sp,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            // "Trending",
                            "Tendecia",
                            style: GoogleFonts.poppins(
                                fontSize: 48.sp, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white,
                            size: 60.sp,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            // "Recent",
                            "Novedades",
                            style: GoogleFonts.poppins(
                                fontSize: 48.sp, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
            backgroundColor: const Color(0XFF101010),
            body: Padding(
              padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 60.h),
              child: TabBarView(children: [
                SingleChildScrollView(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SafeArea(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40.h,
                          ),

                          SizedBox(
                            height: 20.h,
                          ),
                          FutureBuilder(
                              future: fetchProfilePhotos(),
                              builder: (context,
                                  AsyncSnapshot<List<ProfilePhotoData>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text('No data available'),
                                  );
                                }
                                List<ProfilePhotoData> profilePhotos =
                                    snapshot.data!;

                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  childAspectRatio: 0.6,
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 40.w,
                                  crossAxisSpacing: 40.w,
                                  children: List.generate(profilePhotos.length,
                                      (index) {
                                    return ZoomTapAnimation(
                                      onTap: () async {
                                        ProfilePhotoData tappedPhoto =
                                            profilePhotos[index];

                                        print(
                                            'UID of tapped photo: ${tappedPhoto.uid}');

                                        int? postIndex =
                                            await findProfilePhotoIndex(
                                                tappedPhoto.uid,
                                                tappedPhoto.profilePhoto);

                                        await MainViewState().viewPost(
                                            tappedPhoto.uid,
                                            postIndex!,
                                            context);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(26.w),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.sp,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            imageUrl: profilePhotos[index]
                                                .profilePhoto,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              })

                          // //new Trending
                          //                         StreamBuilder(
                          //                           stream: FirebaseFirestore.instance
                          //                               .collection('Users')
                          //                               .snapshots(),
                          //                           builder:
                          //                               (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          //                             if (snapshot.connectionState ==
                          //                                 ConnectionState.waiting) {
                          //                               return Center(
                          //                                 child: CircularProgressIndicator(),
                          //                               );
                          //                             }
                          //                             if (snapshot.hasError) {
                          //                               return Center(
                          //                                 child: Text('Error: ${snapshot.error}'),
                          //                               );
                          //                             }
                          //                             // Process snapshot data
                          //                             final usersDocs =
                          //                                 snapshot.data!.docs; //UIDs collection

                          //                             // Iterate through each user document
                          //                             for (var userDoc in usersDocs) {
                          //                               // Check if the document contains the 'Posts' collection

                          //                               if (userDoc['has_posted']) {
                          //                                 // Fetch posts collection
                          //                                 userDoc.reference
                          //                                     .collection('Posts')
                          //                                     .get()
                          //                                     .then((postsCollection) {
                          //                                   // Iterate through each post

                          //                                   postsCollection.docs.forEach((postSnapshot) {
                          //                                     // Ignore the 'init' document

                          //                                     if (postSnapshot.id != 'init') {
                          //                                       // Extract likes and profile_photo

                          //                                       final likes =
                          //                                           postSnapshot.data()['likes'];

                          //                                       final profilePhoto =
                          //                                           postSnapshot.data()['post_photo'];

                          //                                       final uid = userDoc.id;

                          //                                       profilePhotos.add(ProfilePhotoData(
                          //                                         uid: uid,
                          //                                         profilePhoto: profilePhoto,
                          //                                         likes: likes.length, // Count likes
                          //                                       ));
                          //                                     }
                          //                                   });

                          //                                   // print('fetching done');

                          //                                   // Sort profile photos by likes
                          //                                   profilePhotos.sort(
                          //                                       (a, b) => b.likes.compareTo(a.likes));

                          //                                   // Update the UI

                          //                                   // setState(() {});
                          //                                 });
                          //                               }
                          //                             }
                          // return Column(children: [
                          //   for (int i=0; i<profilePhotos.length;i++)...[
                          //      GestureDetector(
                          //       onTap: (){
                          //   final String uid = profilePhotos[i].uid;
                          //           print(uid);
                          //       },
                          //        child: ListTile(
                          //                                         leading: CircleAvatar(
                          //                                           backgroundImage: NetworkImage(
                          //                                               profilePhotos[i].profilePhoto),
                          //                                         ),
                          //                                         title: Text(
                          //                                             'Likes: ${profilePhotos[i].likes} UID ${profilePhotos[i].uid}'),
                          //                                       ),
                          //      ),
                          //   ]
                          // ],);
                          //                             // return SizedBox(
                          //   height: 2000.h,
                          //   child: ListView.builder(
                          //     itemCount: profilePhotos.length,
                          //     itemBuilder: (context, index) {
                          //       return ZoomTapAnimation(
                          //         onTap: ()async {

                          //         },
                          //         child: ListTile(
                          //           leading: CircleAvatar(
                          //             backgroundImage: NetworkImage(
                          //                 profilePhotos[index].profilePhoto),
                          //           ),
                          //           title: Text(
                          //               'Likes: ${profilePhotos[index].likes} UID ${profilePhotos[index].uid}'),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // );
                          //   },
                          // ),
                          //                       child: GridView.count(
                          //                         childAspectRatio: 0.6,
                          //                         crossAxisCount: 2,
                          //                         mainAxisSpacing: 40.w,
                          //                         crossAxisSpacing: 40.w,
                          //                         children: List.generate(profilePhotos.length,
                          //                             (index) {
                          //                           return ZoomTapAnimation(
                          //                             onTap: () {
                          //                              ProfilePhotoData tappedPhoto = profilePhotos[index];
                          // // Print the UID associated with the tapped photo
                          // print('UID of tapped photo: ${tappedPhoto.uid}');
                          //                             },
                          //                             child: ClipRRect(
                          //                               borderRadius: BorderRadius.circular(40.w),
                          //                               child: SizedBox(
                          //                                 height: 120.h,
                          //                                 width: 120.w,
                          //                                 child: CachedNetworkImage(
                          //                                   placeholder: (context, val) {
                          //                                     return Container(
                          //                                       width: 31.w,
                          //                                       child: Center(
                          //                                         child: Text(
                          //                                           "Loading",
                          //                                           style: TextStyle(
                          //                                             fontWeight: FontWeight.bold,
                          //                                             fontSize: 15.sp,
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     );
                          //                                   },
                          //                                   imageUrl:
                          //                                       profilePhotos[index].profilePhoto,
                          //                                   fit: BoxFit.fill,
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                           );
                          //                         }),
                          //                       ),

                          //old Trending
                          // showProgressIndicator
                          //     ? CircularProgressIndicator()
                          //     //
                          //     : Padding(
                          //         padding: EdgeInsets.symmetric(
                          //           horizontal: 60.w,
                          //         ),
                          //         child: Padding(
                          //           padding: EdgeInsets.only(top: 50.h),
                          //           child: SizedBox(
                          //             height: 100000.h,
                          //             child: GridView.count(
                          //               childAspectRatio: 0.6,
                          //               crossAxisCount: 2,
                          //               mainAxisSpacing: 40.w,
                          //               crossAxisSpacing: 40.w,
                          //               children: List.generate(
                          //                 controller.viralInfoList.length,
                          //                 (index) {
                          //                   return ZoomTapAnimation(
                          //                     onTap: () async {
                          //                       int postIndex = 0;
                          //                       await FirebaseFirestore.instance
                          //                           .collection('Users')
                          //                           .doc(controller
                          //                               .viralList[index][0])
                          //                           .collection('Posts')
                          //                           .get()
                          //                           .then((snapshot) {
                          //                         for (final doc
                          //                             in snapshot.docs) {
                          //                           if (doc.id ==
                          //                               controller
                          //                                       .viralList[index]
                          //                                   [1]) {
                          //                             print(
                          //                                 'Document index: $postIndex');
                          //                             break;
                          //                           }
                          //                           postIndex++;
                          //                         }
                          //                       });

                          //                       // ignore: use_build_context_synchronously
                          //                       await MainViewState().viewPost(
                          //                           controller.viralList[index]
                          //                               [0],
                          //                           postIndex,
                          //                           context);
                          //                     },
                          //                     child: ClipRRect(
                          //                       borderRadius:
                          //                           BorderRadius.circular(40.w),
                          //                       child: SizedBox(
                          //                         height: 120.h,
                          //                         width: 120.w,
                          //                         child: CachedNetworkImage(
                          //                           placeholder: (context, val) {
                          //                             return Container(
                          //                               width: 31.w,
                          //                               child: Center(
                          //                                 child: Text(
                          //                                   "Loading",
                          //                                   style: TextStyle(
                          //                                     fontWeight:
                          //                                         FontWeight.bold,
                          //                                     fontSize: 15.sp,
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             );
                          //                           },
                          //                           imageUrl: controller
                          //                               .viralInfoList[index][1],
                          //                           fit: BoxFit.fill,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                        ],
                      ),
                    )),
                  ),
                ),
                SingleChildScrollView(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60.h,
                        ),

                        //new Recent
                        FutureBuilder<List<ProfilePhotoData>>(
                          future: fetchAllprofilePhotos2SortedByDateTime(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            List<ProfilePhotoData> profilePhotos2 =
                                snapshot.data ?? [];
                            return GridView.count(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              childAspectRatio: 0.6,
                              crossAxisCount: 2,
                              mainAxisSpacing: 40.w,
                              crossAxisSpacing: 40.w,
                              children:
                                  List.generate(profilePhotos2.length, (index) {
                                return ZoomTapAnimation(
                                  onTap: () async {
                                    ProfilePhotoData tappedPhoto =
                                        profilePhotos2[index];

                                    print(
                                        'UID of tapped photo: ${tappedPhoto.uid}');
                                    int? postIndex =
                                        await findProfilePhotoIndex(
                                            tappedPhoto.uid,
                                            tappedPhoto.profilePhoto);

                                    await MainViewState().viewPost(
                                        tappedPhoto.uid, postIndex!, context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.w),
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
                                        imageUrl:
                                            profilePhotos2[index].profilePhoto,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );

                            // return SizedBox(
                            //   height: 1000.h,
                            //   child: ListView.builder(
                            //     itemCount: profilePhotos2.length,
                            //     itemBuilder: (context, index) {
                            //       return ListTile(
                            //         leading: CircleAvatar(
                            //           backgroundImage: NetworkImage(profilePhotos2[index].profilePhoto),
                            //         ),
                            //         title: Text(
                            //           'Likes: ${profilePhotos2[index].likes} UID ${profilePhotos2[index].uid}',
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // );
                          },
                        ),

                        //old Recent
                        // SizedBox(
                        //   height: 100000.h,
                        //   child: GridView.count(
                        //     childAspectRatio: 0.6,
                        //     crossAxisCount: 2,
                        //     mainAxisSpacing: 40.w,
                        //     crossAxisSpacing: 40.w,
                        //     children: List.generate(
                        //       controller.viralInfoList2.length,
                        //       (index) {
                        //         return ZoomTapAnimation(
                        //           onTap: () async {
                        //             print('here');
                        //             print(controller.viralList2);
                        //             int postIndex = 0;
                        //             await FirebaseFirestore.instance
                        //                 .collection('Users')
                        //                 .doc(controller.viralList2[index][0])
                        //                 .collection('Posts')
                        //                 .get()
                        //                 .then((snapshot) {
                        //               for (final doc in snapshot.docs) {
                        //                 if (doc.id ==
                        //                     controller.viralList2[index][1]) {
                        //                   print('Document index: $postIndex');
                        //                   break;
                        //                 }
                        //                 postIndex++;
                        //               }
                        //             });

                        //             // ignore: use_build_context_synchronously
                        //             await MainViewState().viewPost(
                        //                 controller.viralList2[index][0],
                        //                 postIndex,
                        //                 context);
                        //           },
                        //           child: ClipRRect(
                        //             borderRadius: BorderRadius.circular(40.w),
                        //             child: SizedBox(
                        //               height: 120.h,
                        //               width: 120.w,
                        //               child: CachedNetworkImage(
                        //                 placeholder: (context, val) {
                        //                   return Container(
                        //                     width: 31.w,
                        //                     child: Center(
                        //                       child: Text(
                        //                         "Loading",
                        //                         style: TextStyle(
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize: 15.sp,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   );
                        //                 },
                        //                 imageUrl: controller.viralInfoList2[index]
                        //                     [1],
                        //                 fit: BoxFit.fill,
                        //               ),
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ]),
            )),
      ),
    );
  }
}

class ProfilePhotoData {
  final String profilePhoto;
  final int likes;
  final String uid;

  ProfilePhotoData({
    required this.profilePhoto,
    required this.likes,
    required this.uid,
  });
}
