import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_author_client/app/models/chart_line.dart';

class MiniInfoCard extends StatelessWidget {
  double crossAxisSpacing;
  double mainAxisSpacing;
  List<ChartLine> data;
  final double childAspectRatio;

  MiniInfoCard({
    Key? key,
    required this.data,
    this.childAspectRatio = 1,
    this.crossAxisSpacing = 24,
    this.mainAxisSpacing = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _getWidgets(),
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> list = [];
    for (int i = 0; i < data.length; i++) {
      var line = data[i];
      list.add(Expanded(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(0xFF, 0x2A, 0x2A, 0x2A),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              padding: EdgeInsets.fromLTRB(16, 40, 32, 0),
              margin: EdgeInsets.fromLTRB(0, 0, i < data.length - 1 ? 8 : 0, 0), // 设置间隔
              child: LineChart(
                LineChartData(
                  // // 控制图形弯曲度
                  // minX: line.minX,
                  // maxX: line.maxX,
                  // minY: line.minY,
                  // maxY: line.maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: line.spots,
                      aboveBarData: BarAreaData(show: false),
                      isCurved: true,
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: line.colors,
                        ),
                      ),
                    ),
                  ],
                  gridData: FlGridData(
                    show: false,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.amber,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.blue,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  lineTouchData: LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                      // 图表上方标题, 会档住图表
                      // axisNameWidget: Row(
                      //   children: [
                      //     Icon(Icons.search),
                      //     SizedBox(width: 8), // 加入间隔
                      //     Text('Search'),
                      //   ],
                      // ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (line.bottomTitles.isNotEmpty && line.bottomTitles.containsKey(value.toInt())) {
                            return Text(line.bottomTitles[value.toInt()]!, style: TextStyle(color: Colors.grey[250]));
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (line.leftTitles.isNotEmpty && line.leftTitles.containsKey(value.toInt())) {
                            return Text(line.leftTitles[value.toInt()]!, style: TextStyle(color: Colors.grey[250]));
                          } else {
                            return Container();
                          }
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                ),
              ),
            ),
            // 自定义标题
            if (line.title != null)
              Positioned(
                left: 14,
                top: 8,
                child: Row(
                  children: [
                    if (line.icon != null) Icon(line.icon!),
                    if (line.icon != null) SizedBox(width: 8), // 加入间隔
                    Text(
                      line.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ));
    }
    return list;
  }
}
