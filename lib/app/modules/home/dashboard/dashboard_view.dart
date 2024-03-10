import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/models/chart_line.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_card/big_card.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_grid.dart';
import 'package:go_author_client/app/modules/home/dashboard/widget/miniinfo_card.dart';

import 'dashboard_controller.dart';
import 'widget/header.dart';

class DashboardView extends GetView<DashboardController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardView({super.key});

  var chartsData = [
    ChartLine(
      title: "新增",
      colors: [Color(0xff23b6e6), Color(0xff02d39a)],
      leftTitles: {1: "10K", 2: "20K", 3: "30K", 4: "40K", 5: "50k", 6: "60K", 7: "70K", 8: "80K", 9: "90K"},
      bottomTitles: {1: "10M", 2: "20M", 3: "30M", 4: "40M", 5: "50M", 6: "60M", 7: "70M", 8: "80M", 9: "90M"},
      spots: [FlSpot(1, 2), FlSpot(2, 1.0), FlSpot(3, 1.8), FlSpot(4, 1.5), FlSpot(5, 1.0), FlSpot(6, 2.2), FlSpot(7, 1.8), FlSpot(8, 1.5)],
    ),
    ChartLine(
      title: "活跃",
      colors: [Color(0xfff12711), Color(0xfff5af19)],
      leftTitles: {1: "10K", 2: "20K", 3: "30K", 4: "40K", 5: "50k", 6: "60K", 7: "70K", 8: "80K", 9: "90K"},
      bottomTitles: {1: "10M", 2: "20M", 3: "30M", 4: "40M", 5: "50M", 6: "60M", 7: "70M", 8: "80M", 9: "90M"},
      spots: [FlSpot(1, 1.3), FlSpot(2, 1.0), FlSpot(3, 4), FlSpot(4, 1.5), FlSpot(5, 1.0), FlSpot(6, 3), FlSpot(7, 1.8), FlSpot(8, 1.5)],
    ),
    ChartLine(
      title: "Onboarding",
      colors: [Color(0xff2980B9), Color(0xff6DD5FA)],
      leftTitles: {1: "10K", 2: "20K", 3: "30K", 4: "40K", 5: "50k", 6: "60K", 7: "70K", 8: "80K", 9: "90K"},
      bottomTitles: {1: "10M", 2: "20M", 3: "30M", 4: "40M", 5: "50M", 6: "60M", 7: "70M", 8: "80M", 9: "90M"},
      spots: [FlSpot(1, 1.3), FlSpot(2, 5), FlSpot(3, 1.8), FlSpot(4, 6), FlSpot(5, 1.0), FlSpot(6, 2.2), FlSpot(7, 1.8), FlSpot(8, 1)],
    ),
    ChartLine(
      title: "Open Position",
      colors: [Color(0xff93291E), Color(0xffED213A)],
      leftTitles: {1: "10K", 2: "20K", 3: "30K", 4: "40K", 5: "50k", 6: "60K", 7: "70K", 8: "80K", 9: "90K"},
      bottomTitles: {1: "10M", 2: "20M", 3: "30M", 4: "40M", 5: "50M", 6: "60M", 7: "70M", 8: "80M", 9: "90M"},
      spots: [FlSpot(1, 3), FlSpot(2, 4), FlSpot(3, 1.8), FlSpot(4, 1.5), FlSpot(5, 1.0), FlSpot(6, 2.2), FlSpot(7, 1.8), FlSpot(8, 1.5)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Header(nickname: controller.nickname),
            SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: MiniInfoCard(
                data: chartsData,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                BigCard(
                  title: "分组列表",
                  width: 900,
                  height: 500,
                  child: Expanded(
                    child: getDataGrid(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: BigCard(
                    title: "分组列表",
                    height: 500,
                    child: Expanded(
                      child: getDataGrid(pagerVisable: false),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            BigCard(
              title: "分组列表",
              height: 500,
              child: Expanded(
                child: getDataGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDataGrid({double? width, double? height, bool? pagerVisable = true}) {
    return BigDataGrid(
      // key: scaffoldKey,
      // title: "分组管理",
      width: width,
      height: height,
      searchUrl: "/admin/system/group/listPage",
      // insertUrl: "/admin/system/group/insert",
      updateUrl: "/admin/system/group/update",
      deleteUrl: "/admin/system/group/delete",
      // cleanUrl: "/admin/system/group/clean",
      queryParam: QueryParam(),
      pagerVisable: pagerVisable!,
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          allowEditing: false,
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "name",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "分组名",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "note",
          minimumWidth: 120,
          label: "备注",
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "create_time",
          minimumWidth: 240,
          label: "创建时间",
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "update_time",
          minimumWidth: 240,
          label: "更新时间",
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "delete_time",
          minimumWidth: 240,
          label: "删除时间",
          allowEditing: false,
          visible: false,
        ),
      ],
      // searchFields: [],
    );
  }
}
