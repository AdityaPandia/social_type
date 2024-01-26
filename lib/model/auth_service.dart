import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_type/views/authentication/controllers/authentication_controller.dart';
import 'package:social_type/views/authentication/views/google_signup_view.dart';
import 'package:social_type/views/home/views/home_view.dart';

class AuthService {
  emailSignUp() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());

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
            uid, auth.currentUser!.email, authController.nameController.text);
        await storage.write("uid", uid);
        await storage.write('isSignInDone', true);
        authController.isActiveButtonLoading.value = false;

        Get.offAll(() => const HomeView());
      });
    } on FirebaseAuthException catch (e) {
      authController.isActiveButtonLoading.value = false;
      if (e.code == 'weak-password') {
        Get.defaultDialog(
            title: "The password provided is too weak", middleText: "");
      } else if (e.code == 'email-already-in-use') {
        Get.defaultDialog(
            title: "The account already exists for that email", middleText: "");
      } else {
        Get.defaultDialog(title: "$e", middleText: "");
      }
    } catch (e) {
      authController.isActiveButtonLoading.value = false;
      Get.defaultDialog(title: "$e", middleText: "");
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
        Get.defaultDialog(title: "User Not Found", middleText: "");
      } else if (e.code == 'wrong-password') {
        Get.defaultDialog(title: "Wrong Password", middleText: "");
      } else {
        Get.defaultDialog(title: "$e", middleText: "");
      }
    }
  }

  Future<UserCredential> googleAuth() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      Get.defaultDialog(title: "Sign In Cancelled", middleText: "");
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
          Get.offAll(GoogleSignUpView());
        }
      });
    } catch (e) {
      authController.isGoogleLoading.value = false;
      Get.defaultDialog(title: "Something Wrong", middleText: "$e");
    }
  }

  addGoogleUser() async {
    final storage = GetStorage();
    FirebaseAuth auth = FirebaseAuth.instance;
    final authController = Get.put(AuthenticationController());
    String uid = auth.currentUser!.uid;
    authController.isActiveButtonLoading.value = true;
    await addUserToFirestore(
        uid, auth.currentUser!.email, authController.nameController.text);
    await storage.write("uid", uid);
    await storage.write('isSignInDone', true);
    authController.isActiveButtonLoading.value = false;
    Get.offAll(() => const HomeView());
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

  Future<void> addUserToFirestore(
      String uid, String? email, String name) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      await usersCollection.doc(uid).set({
        'email': email,
        'name': name,
        'profile_photo': '',
        'has_posted': false,
        'followers': [],
        'following': [],
      });
    } catch (error) {
      //to show popup
    }
  }
}
