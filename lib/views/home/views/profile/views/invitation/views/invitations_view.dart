import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_type/model/referral_system.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class InvitationsView extends StatelessWidget {
  InvitationsView({super.key});
  RxInt isLoadingIndex = 99.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 87.w),
        child: Column(
          children: [
            Image.asset(
              "assets/images/png/onboarding_khe.png",
              color: Colors.white,
              width: 219.w,
              height: 90.h,
            ),
            SizedBox(
              height: 56.h,
            ),
            Text(
              "Invitaciones disponibles de @ginny",
              style: GoogleFonts.outfit(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            SizedBox(
              height: 93.h,
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('No data available'));
                  }

                  var invitations = snapshot.data!['invitations'];

                  return ListView.builder(
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      String code = invitations[index]['code'];
                      bool used = invitations[index]['used'];

                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white),
                            height: 1.5.sp,
                          ),
                          ListTile(
                            title: Text(
                              code,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                            // trailing: Text(used ? 'True' : 'False'),
                            trailing: Obx(
                              () => SizedBox(
                                width: 385.w,
                                child: Row(
                                  children: [
                                    ZoomTapAnimation(
                                      onTap: () async {
                                        if (isLoadingIndex.value == index) {
                                        } else {
                                          if (used) {
                                          } else {
                                            isLoadingIndex.value = index;
                                            final docRef =
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid);

                                            // Fetch the document
                                            final snapshot = await docRef.get();

                                            // Check if the document exists and has the 'invitations' field
                                            if (snapshot.exists &&
                                                snapshot.data()![
                                                        'invitations'] !=
                                                    null) {
                                              // Get the current invitations array
                                              List<Map<String, dynamic>>
                                                  invitations = List<
                                                          Map<String,
                                                              dynamic>>.from(
                                                      snapshot.data()![
                                                          'invitations']);

                                              // Update the 'has_posted' field of the specific invitation
                                              invitations[index]['used'] = true;

                                              // Update the document with the modified invitations array
                                              await docRef.update(
                                                  {'invitations': invitations});
                                            }
                                            await DynamicLinkProvider()
                                                .createLink("ABCDEFGHI")
                                                .then((value) =>
                                                    Share.share(value));
                                            isLoadingIndex.value = 99;
                                          }
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF696969),
                                            ),
                                            height: 77.sp,
                                            width: 77.sp,
                                          ),
                                          isLoadingIndex.value == index
                                              ? SizedBox(
                                                  height: 57.sp,
                                                  width: 57.sp,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white),
                                                )
                                              : Image.asset(
                                                  "assets/images/png/share_icon_2.png",
                                                  height: 57.sp,
                                                  width: 57.sp,
                                                ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 26.w,
                                    ),
                                    !used
                                        ? Container(
                                            height: 110.h,
                                            width: 279.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.w),
                                                color: Color(0xFFC5D6A1)),
                                            child: Center(
                                                child: Text(
                                              "Disponible",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 40.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                            )),
                                          )
                                        : Container(
                                            height: 110.h,
                                            width: 279.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.w),
                                                color: Color(0xFFD68D8D)),
                                            child: Center(
                                                child: Text(
                                              "Usada",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 40.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                            )),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          index == invitations.length - 1
                              ? Container(
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  height: 1.5.sp,
                                )
                              : SizedBox(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
