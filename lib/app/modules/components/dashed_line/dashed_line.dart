import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final Axis axis; // 水平方向 & 垂直方向
  final double dashedWidth; // 虚线宽度
  final double dashedHeight; // 虚线高度
  final int count; // 虚线总个数
  final Color dashedColor; // 虚线颜色
  double dashedTotalLengthWith; // 虚线水平垂直总长度
  EdgeInsetsGeometry padding;

  DashedLine({
    super.key,
    required this.axis,
    this.dashedWidth = 1,
    this.dashedHeight = 1,
    this.count = 10,
    this.dashedColor = Colors.grey,
    this.dashedTotalLengthWith = 200,
    this.padding = EdgeInsets.zero,
  });

  Widget showDashedLineWidgets() {
    return Padding(
      padding: padding,
      child: Flex(
        direction: axis,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(count, (index) {
          return SizedBox(
            width: dashedWidth,
            height: dashedHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: dashedColor),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return axis == Axis.horizontal
          ? SizedBox(width: dashedTotalLengthWith, child: showDashedLineWidgets())
          : SizedBox(
              height: dashedTotalLengthWith,
              child: showDashedLineWidgets(),
            );
    });
  }
}
