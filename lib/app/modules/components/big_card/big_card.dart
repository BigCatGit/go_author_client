import 'package:flutter/material.dart';

class BigCard extends StatelessWidget {
  String title;
  TextStyle? titleStyle;
  Widget child;
  Color? backgroundColor;
  Widget? leftIcon;
  Widget? rightIcon;
  double? width;
  double? height;
  double? padding;
  BigCard({
    super.key,
    required this.title,
    required this.child,
    this.leftIcon,
    this.rightIcon,
    this.titleStyle,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Color.fromARGB(0xFF, 0x2A, 0x2A, 0x2A),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: EdgeInsets.all(padding!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (this.leftIcon != null) this.leftIcon!,
                    Text(
                      title,
                      style: this.titleStyle ?? TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber),
                    ),
                  ],
                ),
                if (this.rightIcon != null) this.rightIcon!,
              ],
            ),
            SizedBox(height: 16),
            this.child,
          ],
        ),
      ),
    );
  }
}
