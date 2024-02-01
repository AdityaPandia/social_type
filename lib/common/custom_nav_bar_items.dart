import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_type/common/custom_texts.dart';

import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomNavBarItems extends StatelessWidget {
  CustomNavBarItems(
      {super.key,
      required this.isSelected,
      required this.icnPath,
      required this.viewName,
      required this.onPressed, required this.height});
  final bool isSelected;
  final int height;
  final String icnPath;
  final String viewName;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: onPressed,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: isSelected
                  ? EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w)
                  : const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50)),
              child: Image.asset(
                icnPath,
                color: isSelected
                    ? null
                    : const Color(0xFFA2D6FF),
                height: !isSelected ? height.h : (height+2).h,
              ),
            ),
            Text(viewName,
                style: CustomTexts.font20.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFFA2D6FF),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400))
          ],
        ),
      ),
    );
  }
}
