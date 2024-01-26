import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class OnboardingController extends GetxController{
    final onboardingPageController = PageController();
  RxBool isLastPage = false.obs;
}