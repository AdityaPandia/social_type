import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:social_type/common/custom_texts.dart';

class BuildPage extends StatelessWidget {
  const BuildPage({
    required this.onboardingIndex,
    super.key,
    required this.title,
    required this.subTitle,
  });
  final String title;
  final String subTitle;
  final int onboardingIndex;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 50.h,
      ),
      Center(
        child: SizedBox(
          width: 200.w,
          child: Center(
            child: Text(
              "SOCIAL TYPE APP",
              textAlign: TextAlign.center,
              style: CustomTexts.font24
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 20.h,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 82.w),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: CustomTexts.font22.copyWith(
            fontWeight: FontWeight.bold,
            
          ),
        ),
      ),
      SizedBox(height: 20.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 65.w),
        child: Text(
          subTitle,
          textAlign: TextAlign.center,
          style: CustomTexts.font12.copyWith(fontWeight: FontWeight.w400),
        ),
      ),
    ]);
  }
}
