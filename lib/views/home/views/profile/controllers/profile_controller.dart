import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Future<XFile?> pickImageFromGallery() async {
    // Using image_picker package
    final imagePicker = ImagePicker();

    // Pick an image from the gallery
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    // Return the picked image (null if cancelled)
    return pickedFile;
  }

  uploadProfilePhoto() async {
    isLoading.value = true;

    try {
      final taskSnapshot = await pickAndUploadImageToStorage();
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'profile_photo': downloadUrl,
      });
      print('Profile photo uploaded and updated in Firestore!');

      isLoading.value = false;
    } on PlatformException catch (e) {
      isLoading.value = false;
      Get.defaultDialog(  backgroundColor: Color(0xFF353535),
        titlePadding: EdgeInsets.only(top: 14, bottom: 8, left: 10, right: 10),
        titleStyle: GoogleFonts.poppins(
            fontSize: 54.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC6C6C6)),
        middleTextStyle:
            GoogleFonts.poppins(fontSize: 40.sp, color: Color(0xFFC6C6C6)),
        title: "Error",
        middleText: "${e.code}",

        contentPadding: EdgeInsets.all(20),);
      print('Error: ${e.code}');
    }
    isLoading.value = false;
  }

  pickAndUploadImageToStorage() async {
    final XFile? pickedFile = await pickImageFromGallery();

    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_photos/${pickedFile.name}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      return await uploadTask; // Await the completion of the upload task
    } else {
          isLoading.value=false;
          print(isLoading.value);
    showToast("Something's Wrong");

    }
  }
}
