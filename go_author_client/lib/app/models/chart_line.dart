import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartLine {
  String? title;
  IconData? icon;
  List<FlSpot> spots;
  List<Color> colors;
  Map<int, String> leftTitles;
  Map<int, String> bottomTitles;
  Color? belowBarColor;

  ChartLine({
    required this.spots,
    required this.colors,
    this.leftTitles = const {},
    this.bottomTitles = const {},
    this.title,
    this.icon,
  });
}
