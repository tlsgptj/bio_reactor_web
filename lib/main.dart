import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PieChartAndLineChart());
}

class PieChartAndLineChart extends StatefulWidget {
  const PieChartAndLineChart({super.key});

  @override
  State<StatefulWidget> createState() => PieChartAndLineChartState();
}

class PieChartAndLineChartState extends State<PieChartAndLineChart> {
  int touchedIndex = -1;
  List<FlSpot> lineChartSpots = [];
  double pieChartValue1 = 60;
  double pieChartValue2 = 40;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    DatabaseReference lineChartRef = FirebaseDatabase.instance.ref('lineChart');
    lineChartRef.onValue.listen((event) {
      List<FlSpot> spots = [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        spots.add(FlSpot(double.parse(key), value.toDouble()));
      });
      setState(() {
        lineChartSpots = spots;
      });
    });

    DatabaseReference pieChartRef = FirebaseDatabase.instance.ref('pieChart');
    pieChartRef.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        pieChartValue1 = data['value1'].toDouble();
        pieChartValue2 = data['value2'].toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('bioReactor')),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: showingSections(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: lineChartSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 22.0 : 20.0;
      final radius = isTouched ? 80.0 : 75.0;
      final shadows = [BoxShadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xFF444974),
            value: pieChartValue1,
            title: '${pieChartValue1.toInt()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xFFEAECFF),
            value: pieChartValue2,
            title: '${pieChartValue2.toInt()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
}





