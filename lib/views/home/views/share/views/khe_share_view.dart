import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_type/common/custom_colors.dart';
import 'package:social_type/controllers/app_controller.dart';
import 'package:social_type/views/home/views/profile/views/profile_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class KheShareView extends StatelessWidget {
  KheShareView({super.key, required this.document});
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> document;
  List<double> topPosition = [440, 985, 1374, 1248, 719];
  List<double> leftPosition = [125, 78, 78, 600, 600];
  List<double> diameter = [514, 358, 486, 469, 499];
  // Image.asset(document[1]['post_photo']),
  removeValue() {
    document.removeWhere((doc) => doc.id == 'init');
  }

  Future<void> _shareScreenshot() async {
    try {
      final capturedImage =
          await _screenshotController.capture(); // Capture the screenshot
      if (capturedImage != null) {
        final temporaryFile = await _writeImageToTemporaryFile(
            capturedImage); // Save the image to a temporary file
        await Share.shareFiles(
            [temporaryFile.path]); // Share the temporary file
        await temporaryFile
            .delete(); // Clean up the temporary file after sharing
      } else {
        // Handle the case where screenshot capture fails
        print('Failed to capture screenshot.');
      }
    } on PlatformException catch (e) {
      // Handle platform-specific errors (e.g., permissions issues)
      print('Failed to share screenshot: ${e.message}');
    } catch (e) {
      // Handle other unexpected errors
      print('Error sharing screenshot: $e');
    }
  }

  Future<File> _writeImageToTemporaryFile(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final temporaryFilePath = '${directory.path}/screenshot.png';
    final temporaryFile = File(temporaryFilePath);
    await temporaryFile.writeAsBytes(imageBytes);
    return temporaryFile;
  }

  final _screenshotController = ScreenshotController();
  final appController = Get.put(AppController());
  RxBool isShareTapped = false.obs;
  @override
  Widget build(BuildContext context) {
    ProfileViewState()
        .checkIfUserIsVerified(FirebaseAuth.instance.currentUser!.uid);
    removeValue();
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        child: Scaffold(
          body: Stack(
            children: [
              for (int i = 0; i < document.length; i++) ...[
                Positioned(
                  left: leftPosition[i].w,
                  top: topPosition[i].h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2000),
                    child: CachedNetworkImage(
                      height: diameter[i].sp,
                      width: diameter[i].sp,
                      placeholder: (context, val) {
                        return SizedBox(
                          width: 100.w,
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
                      imageUrl: document[i]['post_photo'],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 449.w,
                top: 1140.h,
                child: Image.asset(
                  "assets/images/png/intro_logo.png",
                  height: 90.h,
                  width: 219.w,
                ),
              ),
              Positioned(
                left: 270.w,
                top: 1240.h,
                child: SizedBox(
                  width: 580.w,
                  child: Center(
                    child: Text(
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1890.h,
                left: 505.w,
                child: FutureBuilder(
                    future: appController.getUserProfilePhoto(
                        FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2000),
                          child: CachedNetworkImage(
                            height: 110.sp,
                            width: 110.sp,
                            placeholder: (context, val) {
                              return SizedBox(
                                width: 100.w,
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
                            imageUrl: snapshot.data.toString(),
                            fit: BoxFit.fill,
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
              Positioned(
                top: 2015.h,
                left: 300.w,
                child: SizedBox(
                  width: 514.w,
                  child: Center(
                    child: FutureBuilder(
                        future: appController.getUsername(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text(
                              "@${snapshot.data}",
                              style: GoogleFonts.poppins(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w500,
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
                  ),
                ),
              ),
              Obx(
                () => isShareTapped.value
                    ? Positioned(top: 1, left: 1, child: SizedBox())
                    : Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 600.h),
                          child: ZoomTapAnimation(
                            onTap: () async {
                              isShareTapped.value = true;

                              await _shareScreenshot();
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 200.h,
                              width: 800.w,
                              decoration: BoxDecoration(
                                  color: Color(0xFFD5F601),
                                  borderRadius: BorderRadius.circular(80.w)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    "Tap to Share",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 90.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
