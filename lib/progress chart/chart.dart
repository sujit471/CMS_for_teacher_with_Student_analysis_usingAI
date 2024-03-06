// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter_chart_demo/data/price_point.dart';
//
// class LineChartWidget extends StatefulWidget {
//   const LineChartWidget({Key? key, required this.points}) : super(key: key);
//
//   final List<PricePoint> points;
//
//   @override
//   State<LineChartWidget> createState() => _LineChartWidgetState(points: this.points);
// }
//
// class _LineChartWidgetState extends State<LineChartWidget> {
//   final List<PricePoint> points;
//   late int showingTooltipSpot;
//
//   _LineChartWidgetState({required this.points});
//
//   @override
//   void initState() {
//     showingTooltipSpot = -1;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _lineBarsData = [
//       LineChartBarData(
//           spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
//           isCurved: false,
//           dotData: FlDotData(
//             show: false,
//           ),
//           color: Colors.red
//       ),
//     ];
//     return AspectRatio(
//       aspectRatio: 2,
//       child: LineChart(
//         LineChartData(
//           lineBarsData: _lineBarsData,
//           borderData: FlBorderData(
//               border: const Border(bottom: BorderSide(), left: BorderSide())),
//           gridData: FlGridData(show: false),
//           titlesData: FlTitlesData(
//             bottomTitles: AxisTitles(sideTitles: _bottomTitles),
//             leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           showingTooltipIndicators: showingTooltipSpot != -1 ? [ShowingTooltipIndicators([
//             LineBarSpot(_lineBarsData[0], showingTooltipSpot,
//                 _lineBarsData[0].spots[showingTooltipSpot]),
//           ])] : [],
//           lineTouchData: LineTouchData(
//             enabled: true,
//             touchTooltipData: LineTouchTooltipData(
//               tooltipBgColor: Colors.blue,
//               tooltipRoundedRadius: 20.0,
//               fitInsideHorizontally: true,
//               tooltipMargin: 0,
//               getTooltipItems: (touchedSpots) {
//                 return touchedSpots.map(
//                       (LineBarSpot touchedSpot) {
//                     const textStyle = TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     );
//                     return LineTooltipItem(
//                       points[touchedSpot.spotIndex].y.toStringAsFixed(2),
//                       textStyle,
//                     );
//                   },
//                 ).toList();
//               },
//             ),
//             handleBuiltInTouches: false,
//             touchCallback: (event, response) {
//               if (response?.lineBarSpots != null && event is FlTapUpEvent) {
//                 setState(() {
//                   final spotIndex = response?.lineBarSpots?[0].spotIndex ?? -1;
//                   if(spotIndex == showingTooltipSpot) {
//                     showingTooltipSpot = -1;
//                   }
//                   else {
//                     showingTooltipSpot = spotIndex;
//                   }
//                 });
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   SideTitles get _bottomTitles => SideTitles(
//     showTitles: true,
//     getTitlesWidget: (value, meta) {
//       String text = '';
//       switch (value.toInt()) {
//         case 1:
//           text = 'Jan';
//           break;
//         case 3:
//           text = 'Mar';
//           break;
//         case 5:
//           text = 'May';
//           break;
//         case 7:
//           text = 'Jul';
//           break;
//         case 9:
//           text = 'Sep';
//           break;
//         case 11:
//           text = 'Nov';
//           break;
//       }
//
//       return Text(text);
//     },
//   );
// }