import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthenticationController extends GetxController {
  TextEditingController googleNameController = TextEditingController();

   RxBool isGoogleSignupNext = false.obs;
  RxBool isGoogleSignupLoading = false.obs;
  RxBool isLoginPage=true.obs;
  RxBool isGoogleSignupPage=false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  RxBool isNameDone = false.obs;
  RxBool isPassDone = false.obs;
  RxBool isEmailValid = false.obs;
  RxBool isActiveButtonLoading = false.obs;
  RxBool isGoogleLoading=false.obs;
 
  bool isLoginActive() {
    return (isEmailValid.value && isPassDone.value) ? true : false;
  }

  bool isEmailSignUpActive() {
    return (isEmailValid.value && isPassDone.value && isNameDone.value)
        ? true
        : false;
  }

  bool isGoogleRegisterActive() {
    return isNameDone.value ? true : false;
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
    super.onInit();
  }
}
