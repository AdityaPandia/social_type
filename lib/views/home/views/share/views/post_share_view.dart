import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PostShareView extends StatelessWidget {
  PostShareView({super.key, required this.imageUrl, required this.description});
  final String imageUrl;
  final String description;
  RxBool isShareTapped = false.obs;
  final _screenshotController = ScreenshotController();
  final appController = Get.put(AppController());
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

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 83.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300.h,
              ),
              Image.asset(
                "assets/images/png/intro_logo.png",
                height: 128.h,
                width: 312.w,
              ),
              SizedBox(
                height: 79.h,
              ),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.w),
                    child: SizedBox(
                      height: 1440.h,
                      width: 960.w,
                      child: CachedNetworkImage(
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
                        imageUrl: imageUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60.w,
                        ),
                        FutureBuilder(
                            future: appController.getUserProfilePhoto(
                                FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
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
                        SizedBox(
                          width: 20.w,
                        ),
                        FutureBuilder(
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
                      ],
                    ),
                  ),
                  Obx(
                    () => isShareTapped.value
                        ? SizedBox()
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
                                  width: 800.w,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFD5F601),
                                      borderRadius:
                                          BorderRadius.circular(80.w)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Tap to Share",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 90.sp),
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
              SizedBox(
                height: 50.h,
              ),
              Text(
                "${description}",
                style: GoogleFonts.poppins(
                    fontSize: 65.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD5F600)),
              ),
              SizedBox(
                height: 40.h,
              ),
              Text(
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 40.sp),
              )
            ],
          ),
        )),
      ),
    );
  }
}
