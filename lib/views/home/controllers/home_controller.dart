import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_type/views/home/models/post_model.dart';

class HomeController extends GetxController {
  // PersistentTabController bottomNavController=PersistentTabController(initialIndex: 0);
  RxInt index = 0.obs;
  //  RxBool homeSelected = true.obs;
  // RxBool viralSelected = false.obs;
  // RxBool notificationSelected = false.obs;
  // RxBool profileSelected = false.obs;
  // clearBottomNav() {
  //   homeSelected.value = false;
  //   viralSelected.value = false;
  //   notificationSelected.value = false;
  //   profileSelected.value = false;
  // }

  Future<List<PostModel>> fetchPostsSortedByDateTime() async {
    List<PostModel> posts = [];

    try {
      QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
          in usersSnapshot.docs) {
        String uid = userSnapshot.id;

        QuerySnapshot<Map<String, dynamic>> postsSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(uid)
                .collection('Posts')
                .where(FieldPath.documentId, isNotEqualTo: 'init')
                .get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> postSnapshot
            in postsSnapshot.docs) {
          String postId = postSnapshot.id;
          String postPhoto = postSnapshot['post_photo'];
          List<String> likes = List<String>.from(postSnapshot['likes'] ?? []);
          String description = postSnapshot['description'];
          List<Map<String, String>> comments =
              (postSnapshot['comments'] as List<dynamic>? ?? [])
                  .map<Map<String, String>>((comment) {
            return {
              'userId': comment['userId'] ?? '',
              'text': comment['text'] ?? '',
            };
          }).toList();

          posts.add(PostModel(
            uid: uid,
            postPhoto: postPhoto,
            likes: likes,
            description: description,
            comments: comments,
            // Store the document ID which contains the timestamp
            // We'll extract the timestamp from this ID for sorting
            timeStampId: postId,
          ));
        }
      }

      // Sort the posts based on the timestamp extracted from document IDs
      posts.sort((a, b) =>
          b.timeStampId.compareTo(a.timeStampId)); // Sort in descending order
    } catch (e) {
      print('Error fetching posts: $e');
    }

    return posts;
  }




  Future<List<PostModel>> fetchPostsSortedByLikes() async {
  List<PostModel> posts = [];

  try {
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
        in usersSnapshot.docs) {
      String uid = userSnapshot.id;

      QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(uid)
          .collection('Posts')
          .where(FieldPath.documentId, isNotEqualTo: 'init')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> postSnapshot
          in postsSnapshot.docs) {
        String postId = postSnapshot.id;
        String postPhoto = postSnapshot['post_photo'];
        List<String> likes = List<String>.from(postSnapshot['likes'] ?? []);
        String description = postSnapshot['description'];
        List<Map<String, String>> comments = (postSnapshot['comments'] as List<dynamic>? ?? []).map<Map<String, String>>((comment) {
          return {
            'userId': comment['userId'] ?? '',
            'text': comment['text'] ?? '',
          };
        }).toList();

        posts.add(PostModel(
          uid: uid,
          postPhoto: postPhoto,
          likes: likes,
          description: description,
          comments: comments,
          // Store the document ID which contains the timestamp
          // We'll extract the timestamp from this ID for sorting
        timeStampId: postId,
        ));
      }
    }

    // Sort the posts based on the number of likes
    posts.sort((a, b) => b.likes.length.compareTo(a.likes.length)); // Sort in descending order based on number of likes

  } catch (e) {
    print('Error fetching posts: $e');
  }

  return posts;
}

}
