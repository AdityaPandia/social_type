import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MainController extends GetxController {

  Future<String?> getUsernameByUid(String userUid)async{
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUid).get();

    if (!userDoc.exists) {
      return null; // User document not found
    }

    final username = userDoc.data()!['username'];
    if (username== null) {
      return null; // username field not found or empty
    }

    return username; // Return the username
  }

 
Future<String?>getUserNameByUid(String uid)async{
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

  getCapturedPost(XFile pickedFile) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('user_photos/${pickedFile.name}');
    final uploadTask = storageRef.putFile(File(pickedFile.path));
    return await uploadTask;
  }

  Future<void> addUserIdToFollowers(String ?userId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference uidReferene =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      DocumentSnapshot uidSnapshot = await uidReferene.get();
      Map<String, dynamic> uidData =
          uidSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> followers = uidData['followers'] ?? [];
      if (!followers.contains(currentUserId)) {
        followers.add(currentUserId);
        await uidReferene.update({'followers': followers});
      } else {
        //already follower
      }
      DocumentReference currentUserReference =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);
      DocumentSnapshot currentUserSnapshot = await currentUserReference.get();
      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> following = currentUserData['following'] ?? [];
      following.add(userId);
      await currentUserReference.update({'following': following});
    } catch (e) {
     //error ading
    }
  }

  Future<void> removeUserIdFromFollowers(String ?userId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference uidReference =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      DocumentSnapshot uidSnapshot = await uidReference.get();
      Map<String, dynamic> uidData =
          uidSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> followers = uidData['followers'] ?? [];

      if (followers.contains(currentUserId)) {
        followers.remove(currentUserId);

        await uidReference.update({'followers': followers});
      } else {
      }

      DocumentReference currentUserReference =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);
      DocumentSnapshot currentUserSnapshot = await currentUserReference.get();
      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> following = currentUserData['following'] ?? [];
      following.remove(userId);
      await currentUserReference.update({'following': following});
    } catch (e) {
     //error adding
    }
  }

  Future<bool> isUserIdInFollowers(String ?userId) async {
    try {
      String currentUserId =  FirebaseAuth.instance.currentUser!.uid;
      DocumentReference uidReference =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      DocumentSnapshot uidSnapshot = await uidReference.get();
      Map<String, dynamic> uidData =
          uidSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> followers = uidData['followers'] ?? [];

      return followers.contains(currentUserId);
    } catch (e) {
 //error checking
      return false;
    }
  }

  uploadPost(XFile pickedFile, String description) async {
    try {
      final taskSnapshot = await getCapturedPost(pickedFile);

      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      User? user = FirebaseAuth.instance.currentUser;

      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      DocumentReference userDocument = usersCollection.doc(user!.uid);

      CollectionReference postsCollection = userDocument.collection('Posts');

      DateTime now = DateTime.now();

      DocumentReference postDocument =
          postsCollection.doc(now.toUtc().toIso8601String());

      bool postsCollectionExists = await userDocument
          .collection('Posts')
          .doc('init')
          .get()
          .then((snapshot) => snapshot.exists);

      if (!postsCollectionExists) {
        await userDocument
            .collection('Posts')
            .doc('init')
            .set({'init': 'init'});
      }

      await postDocument.set({
        'post_photo': downloadUrl,
        'description': description,
        'likes': [],
        'comments': [],
      });

   

      await usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'has_posted': true,
      });

  //post updated
    } on PlatformException catch (e) {
      Get.defaultDialog(title: "Error: ${e.code}");
 //error
    }
  }
}
