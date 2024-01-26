import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ViralController extends GetxController {
  RxBool isViralLoading = false.obs;
  List<List<String>> viralList = [];
  String name = "";
  String photo = "";
  List<List<String>> viralInfoList = [];
  getPostDetails(
    String uid,
    String postDocumentId,
  ) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentSnapshot userDoc =
          await firestore.collection('Users').doc(uid).get();
      final DocumentSnapshot postDoc = await firestore
          .collection('Users')
          .doc(uid)
          .collection('Posts')
          .doc(postDocumentId)
          .get();
      final String name = userDoc.get('name');
      final String postPhoto = postDoc.get('post_photo');
      final int likes = postDoc.get('likes').length;

      return {
        'name': name,
        'post_photo': postPhoto,
        'likes': likes,
      };
    } catch (error) {
      print('Error fetching post details: $error');
      return {};
    }
  }

  fetchData() async {
    viralList.clear();
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      for (int i = 0; i < querySnapshot.size; i++) {
        if (querySnapshot.docs[i]['has_posted']) {
          QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
              .collection('Users')
              .doc(querySnapshot.docs[i].id)
              .collection('Posts')
              .get();

          for (int j = 0; j < querySnapshot2.size; j++) {
            if (querySnapshot2.docs[j].id != 'init') {
              RxList<String> tempList = <String>[].obs;

              tempList.add(querySnapshot.docs[i].id);
              tempList.add(querySnapshot2.docs[j].id);
              tempList.add((querySnapshot2.docs[j]['likes'].length).toString());
              viralList.add(tempList);
            }
          }
        }
      }
      viralList.sort((a, b) {
        int likesComparison = int.parse(b[2]).compareTo(int.parse(a[2]));
        if (likesComparison == 0) {
          return a[0].compareTo(b[0]);
        } else {
          return likesComparison;
        }
      });
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
