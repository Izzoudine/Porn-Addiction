import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<History> with AutomaticKeepAliveClientMixin {
  List<DateTime> relapseHistory = [];
  int longestStreak = 0;
  int currentStreak = 0;
  List<FlSpot> weeklyData = [];
  List<FlSpot> monthlyData = [];
  bool showWeekly = true; // Pour alterner entre les graphiques hebdomadaires et mensuels
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('relapseHistory') ?? [];
    
    List<DateTime> dates = history.map((date) => DateTime.parse(date)).toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort in descending order
    
    // Calculate streaks
    if (dates.isNotEmpty) {
      int maxStreak = 0;
      int lastStreak = 0;
      
      for (int i = 0; i < dates.length - 1; i++) {
        final days = dates[i].difference(dates[i + 1]).inDays;
        if (days > maxStreak) maxStreak = days;
        
        if (i == 0) {
          lastStreak = DateTime.now().difference(dates[0]).inDays;
        }
      }
      
      // If there's only one relapse date
      if (dates.length == 1) {
        maxStreak = DateTime.now().difference(dates[0]).inDays;
        lastStreak = maxStreak;
      }
      
      // Generate chart data
      _generateChartData(dates);
      
      setState(() {
        relapseHistory = dates;
        longestStreak = maxStreak;
        currentStreak = lastStreak;
      });
    } else {
      setState(() {
        relapseHistory = [];
        longestStreak = 0;
        currentStreak = 0;
        
        // Generate empty chart data
        weeklyData = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
        monthlyData = List.generate(10, (index) => FlSpot(index.toDouble(), 0));
      });
    }
  }
  
  void _generateChartData(List<DateTime> dates) {
    // Generate weekly data (last 7 days)
    final now = DateTime.now();
    
    // Count relapses per day for the last week
    Map<int, int> weeklyRelapses = {};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayOfWeek = 6 - i; // 6 = today, 0 = 6 days ago
      weeklyRelapses[dayOfWeek] = 0;
      
      for (final date in dates) {
        if (date.year == day.year && date.month == day.month && date.day == day.day) {
          weeklyRelapses[dayOfWeek] = (weeklyRelapses[dayOfWeek] ?? 0) + 1;
        }
      }
    }
    
    // Convert to FlSpot list
    weeklyData = weeklyRelapses.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();
    weeklyData.sort((a, b) => a.x.compareTo(b.x));
    
    // Generate monthly data (last 30 days)
    Map<int, int> monthlyRelapses = {};
    for (int i = 0; i < 30; i += 3) { // Group by 3 days for readability
      final groupIndex = i ~/ 3;
      monthlyRelapses[groupIndex] = 0;
      
      for (int j = 0; j < 3; j++) {
        if (i + j < 30) { // Ensure we don't go beyond 30 days
          final day = now.subtract(Duration(days: i + j));
          
          for (final date in dates) {
            if (date.year == day.year && date.month == day.month && date.day == day.day) {
              monthlyRelapses[groupIndex] = (monthlyRelapses[groupIndex] ?? 0) + 1;
            }
          }
        }
      }
    }
    
    // Convert to FlSpot list
    monthlyData = monthlyRelapses.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();
    monthlyData.sort((a, b) => a.x.compareTo(b.x));
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Your Journey',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Current Streak',
                        '$currentStreak days',
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        'Longest Streak',
                        '$longestStreak days',
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Charts section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress Visualization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Toggle button for chart type
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          showWeekly = !showWeekly;
                        });
                      },
                      icon: Icon(
                        showWeekly ? Icons.calendar_month : Icons.calendar_today,
                        color: Colors.teal,
                      ),
                      label: Text(
                        showWeekly ? 'Weekly' : 'Monthly',
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Chart Container
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.teal.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showWeekly ? 'Weekly Relapses' : 'Monthly Relapses (30 Days)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: showWeekly
                            ? _buildWeeklyChart()
                            : _buildMonthlyChart(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Relapse history header
                const Text(
                  'Relapse History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Relapse history list
                relapseHistory.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No history recorded yet. Stay strong!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: relapseHistory.length,
                        itemBuilder: (context, index) {
                          final date = relapseHistory[index];
                          final formattedDate = DateFormat('MMMM d, yyyy').format(date);
                          
                          // Calculate streak if not the last item
                          String streakText = '';
                          if (index < relapseHistory.length - 1) {
                            final nextDate = relapseHistory[index + 1];
                            final streak = date.difference(nextDate).inDays;
                            streakText = '$streak days clean before this';
                          } else if (relapseHistory.length == 1) {
                            streakText = 'First recorded relapse';
                          } else {
                            streakText = 'Beginning of your journey';
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal.shade50, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.teal.withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.teal,
                                ),
                              ),
                              title: Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                streakText,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              // Ajouter un trailing avec des détails ou actions supplémentaires si nécessaire
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.teal),
                                onPressed: () {
                                  // Show more details or notes about this relapse
                                  // You can implement this later
                                },
                              ),
                            ),
                          );
                        },
                      ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return weeklyData.isEmpty
        ? const Center(child: Text('No data available'))
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.teal.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.teal.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('0');
                      } else if (value % 1 == 0) {
                        return Text(value.toInt().toString());
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final labels = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                      final index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyData,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.teal.withOpacity(0.6), Colors.teal],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.teal,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withOpacity(0.3),
                        Colors.teal.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.x.toInt();
                      final labels = ['6 days ago', '5 days ago', '4 days ago', '3 days ago', '2 days ago', 'Yesterday', 'Today'];
                      return LineTooltipItem(
                        '${labels[index]}\n${barSpot.y.toInt()} relapses',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          );
  }

  Widget _buildMonthlyChart() {
    return monthlyData.isEmpty
        ? const Center(child: Text('No data available'))
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.amber.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.amber.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('0');
                      } else if (value % 1 == 0) {
                        return Text(value.toInt().toString());
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      // Convert index to days ago (each index represents 3 days)
                      final daysAgo = 30 - (index * 3);
                      
                      if (index >= 0 && index < 10) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            daysAgo <= 0 ? 'Now' : '$daysAgo d',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: monthlyData,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.6), Colors.amber],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.amber,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.amber.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.x.toInt();
                      // Calculate days range for this group
                      final endDay = 30 - (index * 3);
                      final startDay = endDay - 2 > 0 ? endDay - 2 : 0;
                      final dayRange = startDay == 0 
                          ? 'Last $endDay days' 
                          : 'Day $startDay-$endDay ago';
                      
                      return LineTooltipItem(
                        '$dayRange\n${barSpot.y.toInt()} relapses',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}