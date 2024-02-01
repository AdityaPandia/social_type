import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/common/custom_texts.dart';
import 'package:social_type/views/home/views/main/views/main_view.dart';
import 'package:social_type/views/home/views/viral/controllers/viral_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ViralView extends StatefulWidget {
  ViralView({super.key});

  @override
  State<ViralView> createState() => _ViralViewState();
}

class _ViralViewState extends State<ViralView> {
  final controller = Get.put(ViralController());
  bool showProgressIndicator = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showProgressIndicator = false;
      });
    });
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
                SizedBox(
                  width: 600.w,
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Search User..."),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0XFF101010),
          bottom: TabBar(
              dividerColor: Color(0xFF101010),
              indicatorColor: Color(0xFF101010),
              tabs: [
                Text(
                  "Trending",
                  style:
                      GoogleFonts.poppins(fontSize: 48.sp, color: Colors.white),
                ),
                Text(
                  "Recent",
                  style:
                      GoogleFonts.poppins(fontSize: 48.sp, color: Colors.white),
                ),
              ]),
        ),
        backgroundColor: const Color(0XFF101010),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "TRENDING",
                  style: CustomTexts.font16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.backgroundColor,
                  ),
                ),
                SizedBox(
                  height: 0.h,
                ),
                FutureBuilder(
                  future: controller.fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    controller.viralInfoList.clear();
                    return SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                          itemCount: controller.viralList.length,
                          itemBuilder: ((context, index) {
                            print(controller.viralList);

                            controller
                                .getPostDetails(controller.viralList[index][0],
                                    controller.viralList[index][1])
                                .then((result) {
                              RxList<String> temp = <String>[
                                controller.viralList[index][0],
                                result['post_photo'],
                                (result['likes']).toString()
                              ].obs;
                              controller.viralInfoList.add(temp);

                              controller.viralInfoList.sort((a, b) {
                                int likesComparison =
                                    int.parse(b[2]).compareTo(int.parse(a[2]));
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
                        padding: EdgeInsets.symmetric(horizontal: 58.w),
                        child: SizedBox(
                          height: 5000.h,
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 77.w,
                            crossAxisSpacing: 77.w,
                            children: List.generate(
                              controller.viralInfoList.length,
                              (index) {
                                return ZoomTapAnimation(
                                  onTap: () async {
                                    int postIndex = 0;
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(controller.viralList[index][0])
                                        .collection('Posts')
                                        .get()
                                        .then((snapshot) {
                                      for (final doc in snapshot.docs) {
                                        if (doc.id ==
                                            controller.viralList[index][1]) {
                                          print('Document index: $postIndex');
                                          break;
                                        }
                                        postIndex++;
                                      }
                                    });

                                    // ignore: use_build_context_synchronously
                                    await MainViewState().viewPost(
                                        controller.viralList[index][0],
                                        postIndex,
                                        context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.w),
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
                                            controller.viralInfoList[index][1],
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
              ],
            ),
          )),
        ),
      ),
    );
  }
}
