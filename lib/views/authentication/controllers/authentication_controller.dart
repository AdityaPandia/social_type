import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  Future<bool> checkInvitationCode(String code) async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    for (final userDoc in usersSnapshot.docs) {
      List<dynamic> invitations = userDoc.data()['invitations'];
      print(invitations);
      print("HEY THERE");
      if (invitations != null) {
        // Loop through the invitations to check the code and its usage
        for (var invitation in invitations) {
          if (invitation['code'] == code) {
            if (invitation['used'] == false) {
              // Invitation code is valid and not used
              print('Valid invitation code');
              // Do whatever you want here
              return true;
            } else {
              // Invitation code is valid but already used
              print('Invitation code already used');
              // Handle accordingly
              return false;
            }
          }
        }
      }
    }

    // Invitation code not found in any user document or user documents don't exist
    print('Invalid invitation code');
    return false;
    // Handle accordingly
  }

  TextEditingController googleNameController = TextEditingController();

  RxBool isGoogleSignupNext = false.obs;
  RxBool isGoogleSignupLoading = false.obs;
  RxBool isLoginPage = true.obs;
  RxBool isGoogleSignupPage = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController invitationCodeController = TextEditingController();
  RxBool isUserNameDone = false.obs;
  RxBool isNameDone = false.obs;
  RxBool isPassDone = false.obs;
  RxBool isEmailValid = false.obs;
  RxBool isActiveButtonLoading = false.obs;
  RxBool isGoogleLoading = false.obs;
  RxBool isInvitationCodeDone = false.obs;

  bool isLoginActive() {
    return (isEmailValid.value && isPassDone.value) ? true : false;
  }

  bool isEmailSignUpActive() {
    return (isEmailValid.value &&
            isPassDone.value &&
            isNameDone.value &&
            isUserNameDone.value &&
            isInvitationCodeDone.value)
        ? true
        : false;
  }

  bool isGoogleRegisterActive() {
    return isNameDone.value && isInvitationCodeDone.value ? true : false;
  }

  @override
  void onInit() {
    googleNameController.addListener(() {
      isGoogleSignupNext.value = googleNameController.text.isNotEmpty;
    });
    passController.addListener(() {
      isPassDone.value = passController.text.isNotEmpty;
    });
    nameController.addListener(() {
      isNameDone.value = nameController.text.isNotEmpty;
    });
    userNameController.addListener(() {
      isUserNameDone.value = userNameController.text.isNotEmpty;
    });
    invitationCodeController.addListener(() {
      isInvitationCodeDone.value = invitationCodeController.text.isNotEmpty;
    });
    super.onInit();
  }
}
