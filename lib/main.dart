import 'package:chartdemo/zoomable_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// normally bottomTitles can't overlap the chart and therefore we normally cant
  /// have custom drawing overlaing the chart at the postion of spots (==titles).
  /// To make that possible, we make the titles as big as the chart, and the chart
  /// twice as big, but inside an overflobox that only shows half of it. inside, we
  /// translate the chart down and the titles up to meet in the middle.
  /// to make all that possible, we need to define a size for the chart.
  double chartHeight = 220;

  List<FlSpot> dataPoints = [];

  @override
  void initState() {
    super.initState();

    List<List<double>> data = [
      [0, 2],
      [1, 4],
      [2, 4],
      [3, 2],
      [4, 3],
      [5, 5],
      [6, 2],
      [7, 6],
      [8, 3],
      [9, 7],
      [10, 2],
      [11, 4],
      [12, 8],
      [13, 7],
      [14, 3],
      [15, 5],
      [16, 2],
      [17, 6],
      [18, 3],
      [19, 7],
    ];

    for (var dataP in data) {
      FlSpot newSpot;
      newSpot = FlSpot(dataP.first, dataP.last);
      dataPoints.add(newSpot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ZoomableChart(
          key: UniqueKey(),
          minX: 3,
          maxX: 20,
          minPointsToShow: 7,
          builder: (minX1, maxX1) {
            return ConstrainedBox(
              // constrain chart to desired height.
              constraints: BoxConstraints.tightFor(height: chartHeight),
              // make chart twice its own size to make room for overlayn titles
              child: OverflowBox(
                maxHeight: chartHeight * 2,
                minHeight: chartHeight * 2,
                child: Transform.translate(
                  // bc chart is de facto twice its height, move chart to "bottom"
                  offset: Offset(0, chartHeight / 2),
                  child: ClipRect(
                    child: LineChart(
                      duration: const Duration(milliseconds: 30),
                      LineChartData(
                        lineTouchData: const LineTouchData(enabled: false),
                        clipData: const FlClipData.none(),
                        minX: minX1,
                        maxX: maxX1,
                        minY: 0,
                        maxY: 10,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              interval: 1,
                              showTitles: true,
                              reservedSize:
                                  // bc titles should overlay chart, give them same size
                                  chartHeight,
                              getTitlesWidget: ((value, meta) => Transform.translate(
                                    // bc chart is de facto twice its height, move titles to "bottom"
                                    offset: Offset(0.0, -chartHeight),
                                    child: Container(
                                      width: 20,
                                      color: Colors.lightBlue,
                                      child: const RotatedBox(
                                          quarterTurns: 1, child: Center(child: Text("custom overlay title"))),
                                    ),
                                  )),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        // Lines
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            isStrokeCapRound: true,
                            isStrokeJoinRound: true,
                            preventCurveOverShooting: true,
                            barWidth: 2,
                            color: Colors.red,
                            dotData: FlDotData(
                              getDotPainter: (dot, a, data, i) => FlDotCirclePainter(
                                radius: 3,
                                color: Colors.amber,
                              ),
                              show: true,
                            ),
                            spots: dataPoints,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
