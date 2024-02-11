import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/_http/utils/body_decoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_type/common/custom_colors.dart';
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

  TextEditingController searchController = TextEditingController();

  String _searchQuery = '';

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
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Search User..."),
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
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No users found'),
                        );
                      }

                      return Container(
                        margin: EdgeInsets.all(60.w),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(80.w)),
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
                                    Get.to(() => ProfileView(userUid: user.id));
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
          ],
        ),
      ),
    );
  }
}
