import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StudentMarksChart extends StatelessWidget {
  List<ChartData> chartData = [
    ChartData('2015', 70),
    ChartData('2016', 75),
    ChartData('2017', 80),
    ChartData('2018', 85),
    ChartData('2019', 90),
    ChartData('2020', 95),
    ChartData('2021', 80),
    ChartData('2022', 78),
    ChartData('2023', 85),
  ];

  StudentMarksChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Pass Percentage'),
      ),
      body: Center(
        child: Container(
          height: 300,
          padding: EdgeInsets.all(16.0),
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotate labels for better readability
            ),
            series: <CartesianSeries>[
              LineSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.year,
                yValueMapper: (ChartData data, _) => data.passpercentage,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                ),
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String year;
  final double passpercentage;

  ChartData(this.year, this.passpercentage);
}
