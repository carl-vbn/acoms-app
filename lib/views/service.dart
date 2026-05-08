import 'package:acoms_app/models/service.dart';
import 'package:acoms_app/models/stats.dart';
import 'package:acoms_app/remote.dart';
import 'package:acoms_app/widgets/fictional.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatsGraph extends StatelessWidget {
  final StatsSlice stats;
  final selectedPropertyIndex;

  const StatsGraph({super.key, required this.stats, required this.selectedPropertyIndex});

  @override
  Widget build(BuildContext context) {
    final property = selectedPropertyIndex == 0 ? stats.pageViewsPerDay : stats.uniqueActorsPerDay;

    return BarChart(
      BarChartData(
        barGroups: property != null
            ? List.generate(property.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: property[index].toDouble(),
                      borderRadius: BorderRadius.zero,
                      color: FiColors.primary,
                    )
                  ],
                );
              })
            : [],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int timestamp = stats.sliceStart + value.toInt() * 24 * 60 * 60;
                DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                if (date.day % 5 != 0) {
                  return const SizedBox.shrink();
                }

                final dateStr = DateFormat('MM/dd').format(date);

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(dateStr, style: TextStyle(color: FiColors.mainText, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return Text(value.toInt().toString(), style: TextStyle(color: FiColors.mainText, fontSize: 10));
              },
            ),
          ),
          // Hide the other axes if you don't need them
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              int timestamp = stats.sliceStart + group.x.toInt() * 24 * 60 * 60;
              DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              final dateStr = DateFormat('MM/dd/yyyy').format(date);
              return BarTooltipItem(
                '$dateStr\n${rod.toY.toInt()} page views',
                TextStyle(color: FiColors.mainText, fontSize: 12),
              );
            },
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
      duration: Duration(milliseconds: 150), // Optional
      curve: Curves.linear, // Optional
    );
  }
}

class StatsWidget extends StatefulWidget {
  final Service service;

  const StatsWidget({super.key, required this.service});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  final formatter = NumberFormat('#,###');
  final remote = Remote();

  Future<StatsSlice>? _statsFuture;

  int _selectedStatIndex = 0;
  int _selectedTimeRangeIndex = 1;

  Widget _timeRangeButton(String label, int index) {
    return TextButton(
      onPressed: () {
        setState(() => _selectedTimeRangeIndex = index);
        loadStats();
      },
      style: TextButton.styleFrom(
        fixedSize: Size(45, 45),
        minimumSize: Size.zero,
        foregroundColor: FiColors.primary,
        backgroundColor: _selectedTimeRangeIndex == index ? Colors.black : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: FiColors.border, width: 2),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 8, letterSpacing: -1), overflow: TextOverflow.clip,),
    );
  }

  void loadStats() {
    int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int sliceStart = secondsSinceEpoch - [7, 30, 90][_selectedTimeRangeIndex] * 24 * 60 * 60;
    int sliceEnd = secondsSinceEpoch;
    setState(() {
      _statsFuture = remote.stats.retrieveStats(widget.service.id, sliceStart, sliceEnd);
    });
  }

  @override
  void initState() {
    loadStats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FiHeading(primaryText: 'STATS'),
        FutureBuilder(future: _statsFuture, builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: FiRowElement(label: 'SESSIONS', value: formatter.format(stats.sessionCount))),
                    Expanded(child: FiRowElement(label: 'ACTORS', value: formatter.format(stats.actorCount))),
                    Expanded(child: FiRowElement(label: 'AVG SPA', value: stats.sessionsPerActor.toStringAsFixed(2))),
                    Expanded(child: FiRowElement(label: 'AVG VPS', value: stats.viewsPerSession.toStringAsFixed(2), isLastH: true)),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: FiColors.border, width: 2),
                    color: FiColors.controlBackground
                  ),
                  padding: EdgeInsets.all(30),
                  child: Column(
                    spacing: 30,
                    children: [
                      SizedBox(height: 300, child: StatsGraph(stats: stats, selectedPropertyIndex: _selectedStatIndex)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Stat type button group
                          FiSelector(
                            options: ["PAGE VIEWS", "UNIQUE ACTORS"],
                            selectedIndex: _selectedStatIndex,
                            onSelected: (index) {
                              setState(() => _selectedStatIndex = index);
                              loadStats();
                            }
                          ),
                          Row(
                            spacing: 3,
                            children: [
                              _timeRangeButton("7d", 0),
                              _timeRangeButton("30d", 1),
                              _timeRangeButton("90d", 2),
                            ],
                          )
                        ],
                      ),
                    ],
                  )
                )
              ],
            );
          } else {
            return const Text('No data available');
          }
        })
      ],
    );
  }
}

class ServiceView extends StatelessWidget {
  final Service service;

  const ServiceView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            FiHeading(primaryText: 'OVERVIEW'),
            Column(
              children: [
                Row(
                  children: [
                    FiRowElement(
                      label: 'SERVICE ID',
                      value: service.id,
                    ),
                    Expanded(child: FiRowElement(label: 'DESCRIPTION', value: service.description)),
                    FiRowElement(
                      label: 'STATUS',
                      value: service.status,
                      isLastH: true,
                    )
                  ],
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FiRowElement(
                          label: 'HOST',
                          value: service.host,
                          isLastV: true
                        ),
                      ),
                      FiButton(text: "VISIT", onPressed: (){
                        launchUrlString(service.url, mode: LaunchMode.platformDefault);
                      }, isLastH: true, isLastV: true),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            StatsWidget(service: service),
          ]
        )
      ),
    );
  }
}
