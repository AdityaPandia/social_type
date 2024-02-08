import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class AppController extends GetxController {
Future<String?> getUsername()async{
   String uid = await GetStorage().read('uid');
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (!userDoc.exists) {
      return null; // User document not found
    }

    final username = userDoc.data()!['username'];
    if (username== null) {
      return null; // username field not found or empty
    }

    return username; // Return the username
}

  Future<String?> getUserEmail() async {
    String uid = await GetStorage().read('uid');
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (!userDoc.exists) {
      return null; // User document not found
    }

    final email = userDoc.data()!['email'];
    if (email == null) {
      return null; // Email field not found or empty
    }

    return email; // Return the email address
  }

  Future<String?> getUserName() async {
    String uid = await GetStorage().read('uid');
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (!userDoc.exists) {
      return null; // User document not found
    }

    final name = userDoc.data()!['name'];
    if (name == null) {
      return null; // Email field not found or empty
    }

    return name; // Return the email address
  }

  Future<String?> getUserProfilePhoto() async {
    String uid = await GetStorage().read('uid');
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (!userDoc.exists) {
      return null; // User document not found
    }

    final profilePhoto = userDoc.data()!['profile_photo'];
    if (profilePhoto == null) {
      return null; // Email field not found or empty
    }

    return profilePhoto; // Return the email address
  }
}
