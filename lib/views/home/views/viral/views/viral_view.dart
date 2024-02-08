import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
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
  bool showProgressIndicator = true;

  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

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
      child: Scaffold(
          appBar: AppBar(
            title: Container(
              margin: EdgeInsets.only(top: 30.h),
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(80.w)),
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
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search User..."),
                        ),
                      ),
                    ],
                  ),
                ],
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
                          "Trending",
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
                          "Recent",
                          style: GoogleFonts.poppins(
                              fontSize: 48.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
          backgroundColor: const Color(0XFF101010),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => Column(
                      children: [
                        controller.isSearchActive.value
                            ? StreamBuilder(
                                stream: _searchQuery.isEmpty
                                    ? FirebaseFirestore.instance
                                        .collection('Users')
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Users')
                                        .where('username',
                                            isGreaterThanOrEqualTo:
                                                _searchQuery)
                                        .where('username',
                                            isLessThan: _searchQuery + 'z')
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text('No users found'),
                                    );
                                  }

                                  return Container(
                                    margin: EdgeInsets.all(60.w),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(80.w)),
                                    height: 800.h,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 80.w, top: 50.h, bottom: 50.h),
                                      child: ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          var user = snapshot.data!.docs[index];
                                          return ListTile(
                                            title: ZoomTapAnimation(
                                              onTap: () {
                                                Get.to(() => ProfileView(
                                                    userUid: user.id));
                                              },
                                              child: Text(
                                                user['username'],
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            // You can add more details or actions here
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 20.h,
                        ),
                        FutureBuilder(
                          future: controller.fetchData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(); //cpi
                            }
                            controller.viralInfoList.clear();
                            return SizedBox(
                              height: 40.h,
                              child: ListView.builder(
                                  itemCount: controller.viralList.length,
                                  itemBuilder: ((context, index) {
                                    print(controller.viralList);

                                    controller
                                        .getPostDetails(
                                            controller.viralList[index][0],
                                            controller.viralList[index][1])
                                        .then((result) {
                                      RxList<String> temp = <String>[
                                        controller.viralList[index][0],
                                        result['post_photo'],
                                        (result['likes']).toString()
                                      ].obs;
                                      //sort viralList2 here
                                      sortViralList(controller.viralList2);
                                      RxList<String> temp2 = <String>[
                                        controller.viralList2[index][0],
                                        result['post_photo'],
                                        (result['likes']).toString()
                                      ].obs;
                                      controller.viralInfoList.add(temp);
                                      controller.viralInfoList2.add(temp2);
                                      print("Here");
                                      print(controller.viralList2);
                                      print(controller.viralInfoList2);
                                      controller.viralInfoList.sort((a, b) {
                                        int likesComparison = int.parse(b[2])
                                            .compareTo(int.parse(a[2]));
                                        if (likesComparison == 0) {
                                          return a[0].compareTo(b[0]);
                                        } else {
                                          return likesComparison;
                                        }
                                      });
                                    });
                                    return SizedBox();
                                  })),
                            );
                          },
                        ),
                        showProgressIndicator
                            ? CircularProgressIndicator()
                            //
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 60.w,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50.h),
                                  child: SizedBox(
                                    height: 100000.h,
                                    child: GridView.count(
                                      childAspectRatio: 0.6,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 40.w,
                                      crossAxisSpacing: 40.w,
                                      children: List.generate(
                                        controller.viralInfoList.length,
                                        (index) {
                                          return ZoomTapAnimation(
                                            onTap: () async {
                                              int postIndex = 0;
                                              await FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(controller
                                                      .viralList[index][0])
                                                  .collection('Posts')
                                                  .get()
                                                  .then((snapshot) {
                                                for (final doc
                                                    in snapshot.docs) {
                                                  if (doc.id ==
                                                      controller
                                                              .viralList[index]
                                                          [1]) {
                                                    print(
                                                        'Document index: $postIndex');
                                                    break;
                                                  }
                                                  postIndex++;
                                                }
                                              });

                                              // ignore: use_build_context_synchronously
                                              await MainViewState().viewPost(
                                                  controller.viralList[index]
                                                      [0],
                                                  postIndex,
                                                  context);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40.w),
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
                                                  imageUrl: controller
                                                      .viralInfoList[index][1],
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )),
              ),
            ),
            SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 58.w),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.h,
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
                                      .where('username',
                                          isLessThan: _searchQuery + 'z')
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: SizedBox(), //cpi
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Text('No users found'),
                                  );
                                }

                                return Container(
                                  margin: EdgeInsets.all(60.w),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                          BorderRadius.circular(80.w)),
                                  height: 800.h,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 80.w, top: 50.h, bottom: 50.h),
                                    child: ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var user = snapshot.data!.docs[index];
                                        return ListTile(
                                          title: ZoomTapAnimation(
                                            onTap: () {
                                              Get.to(() => ProfileView(
                                                  userUid: user.id));
                                            },
                                            child: Text(
                                              user['username'],
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          // You can add more details or actions here
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 100000.h,
                        child: GridView.count(
                          childAspectRatio: 0.6,
                          crossAxisCount: 2,
                          mainAxisSpacing: 40.w,
                          crossAxisSpacing: 40.w,
                          children: List.generate(
                            controller.viralInfoList2.length,
                            (index) {
                              return ZoomTapAnimation(
                                onTap: () async {
                                  print('here');
                                  print(controller.viralList2);
                                  int postIndex = 0;
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(controller.viralList2[index][0])
                                      .collection('Posts')
                                      .get()
                                      .then((snapshot) {
                                    for (final doc in snapshot.docs) {
                                      if (doc.id ==
                                          controller.viralList2[index][1]) {
                                        print('Document index: $postIndex');
                                        break;
                                      }
                                      postIndex++;
                                    }
                                  });

                                  // ignore: use_build_context_synchronously
                                  await MainViewState().viewPost(
                                      controller.viralList2[index][0],
                                      postIndex,
                                      context);
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
                                      imageUrl: controller.viralInfoList2[index]
                                          [1],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ])),
    );
  }
}
