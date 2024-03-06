import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oktoast/oktoast.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/google_signup_view.dart';
import 'package:social_type/views/authentication/views/profile_photo_view.dart';
import 'package:social_type/views/home/views/home_view.dart';

class AuthService {
  Future<bool> doesUsernameExist(String username) async {
    final _firestore = FirebaseFirestore.instance;

    final querySnapshot = await _firestore
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  emailSignUp() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());

    if (await doesUsernameExist(authController.userNameController.text)) {
      showToast("Username Already Exists",
          position: ToastPosition(align: Alignment.bottomCenter));
    }
    try {
      authController.isActiveButtonLoading.value = true;
      await auth
          .createUserWithEmailAndPassword(
        email: authController.emailController.text,
        password: authController.passController.text,
      )
          .then((value) async {
        String uid = auth.currentUser!.uid;
        await addUserToFirestore(
            uid,
            auth.currentUser!.email,
            authController.nameController.text,
            authController.userNameController.text);
        await storage.write("uid", uid);
        await storage.write('isSignInDone', true);
        authController.isActiveButtonLoading.value = false;

        // Get.offAll(() => const HomeView());
        Get.offAll(() => ProfilePhotoView());
      });
    } on FirebaseAuthException catch (e) {
      authController.isActiveButtonLoading.value = false;
      if (e.code == 'weak-password') {
        showToast("The password provided is too weak",
            position: ToastPosition(align: Alignment.bottomCenter));
      } else if (e.code == 'email-already-in-use') {
        showToast("The account already exists for that email",
            position: ToastPosition(align: Alignment.bottomCenter));
      } else {
        showToast("$e", position: ToastPosition(align: Alignment.bottomCenter));
      }
    } catch (e) {
      authController.isActiveButtonLoading.value = false;
      showToast("$e", position: ToastPosition(align: Alignment.bottomCenter));
    }
  }

  emailLogIn() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());
    try {
      authController.isActiveButtonLoading.value = true;
      await auth
          .signInWithEmailAndPassword(
        email: authController.emailController.text,
        password: authController.passController.text,
      )
          .then((value) async {
        String uid = auth.currentUser!.uid;
        await storage.write("uid", uid);
        await storage.write('isSignInDone', true);
        authController.isActiveButtonLoading.value = false;
        Get.offAll(() => const HomeView());
      });
    } on FirebaseAuthException catch (e) {
      authController.isActiveButtonLoading.value = false;
      if (e.code == 'user-not-found') {
        showToast("User Not Found",
            position: ToastPosition(align: Alignment.bottomCenter));
      } else if (e.code == 'wrong-password') {
        showToast("Wrong Password",
            position: ToastPosition(align: Alignment.bottomCenter));
      } else {
        showToast("$e", position: ToastPosition(align: Alignment.bottomCenter));
      }
    }
  }

  Future<UserCredential> googleAuth() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      showToast("Google Signin Cancelled");
      // Get.defaultDialog(   backgroundColor: Color(0xFF353535),
      //   titlePadding: EdgeInsets.only(top: 14, bottom: 8, left: 10, right: 10),
      //   titleStyle: GoogleFonts.poppins(
      //       fontSize: 54.sp,
      //       fontWeight: FontWeight.w500,
      //       color: Color(0xFFC6C6C6)),
      //   middleTextStyle:
      //       GoogleFonts.poppins(fontSize: 40.sp, color: Color(0xFFC6C6C6)),
      //   title: "Error",
      //   middleText: "User cancelled sign in",

      //   contentPadding: EdgeInsets.all(20),);
      throw Exception("User denied sign in");
    }
    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    return await auth.signInWithCredential(credential);
  }

  signInWithGoogle() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());
    try {
      authController.isGoogleLoading.value = true;
      await googleAuth().then((value) async {
        String uid = auth.currentUser!.uid;
        int userExists = await doesUserExist(uid);
        if (userExists == 1) {
          await storage.write("uid", uid);
          await storage.write('isSignInDone', true);
          authController.isGoogleLoading.value = false;
          Get.offAll(() => const HomeView());
        } else if (userExists == 0) {
          authController.isGoogleLoading.value = false;
          // Get.offAll(GoogleSignUpView());
          authController.isGoogleSignupPage.value = true;
        }
      });
    } catch (e) {
      authController.isGoogleLoading.value = false;
      showToast("Something's Wrong",
          position: ToastPosition(
            align: Alignment.bottomCenter,
          ));
    }
  }

  addGoogleUser() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());

    String uid = auth.currentUser!.uid;
    authController.isActiveButtonLoading.value = true;
    await addUserToFirestore(
        uid,
        auth.currentUser!.email,
        authController.nameController.text,
        authController.userNameController.text);
    await storage.write("uid", uid);
    await storage.write('isSignInDone', true);
    authController.isActiveButtonLoading.value = false;
    // Get.offAll(() => const HomeView());
    Get.offAll(() => ProfilePhotoView());
  }

  Future<int> doesUserExist(String uid) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      DocumentSnapshot userSnapshot = await usersCollection.doc(uid).get();

      if (userSnapshot.exists) {
        return 1;
      } else {
        return 0;
      }
    } catch (error) {
      return 2;
    }
  }

  String generateRandomString(int length) {
    final random = Random();
    final chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    String code = '';
    for (var i = 0; i < length; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  addUserToFirestore(
      String uid, String? email, String name, String userName) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      await usersCollection.doc(uid).set({
        'email': email,
        'name': name,
        'username': userName,
        'profile_photo': '',
        'has_posted': false,
        'followers': [],
        'following': [],
        'requests': [],
        'verified_user': false,
        'vip_user': false,
        'invitations': [
          // Add multiple invitations with random codes and false 'used' values
          {
            'code': generateRandomString(10), // Adjust code length as needed
            'used': false,
          },
          {
            'code': generateRandomString(10),
            'used': false,
          },
          {
            'code': generateRandomString(10),
            'used': false,
          },
          // ... Add more invitations as required
        ],
      });
    } catch (error) {
      //to show popup
    }
  }
}
