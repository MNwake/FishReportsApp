import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/length_data.dart';

class LengthDistributionChart extends StatelessWidget {
  final List<LengthData> graphData;
  final bool useCaching;

  const LengthDistributionChart({
    super.key,
    required this.graphData,
    this.useCaching = true,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty data case
    if (graphData.isEmpty) {
      return const Center(
        child: Text('No length distribution data available'),
      );
    }

    // Sort and process data - do this once
    final sortedData = List<LengthData>.from(graphData)
      ..sort((a, b) => a.length.compareTo(b.length));

    // Calculate key points for labels
    final lengths = sortedData.map((d) => d.length).toList();
    final midIndex = lengths.length ~/ 2;
    final q1Index = lengths.length ~/ 4;
    final q3Index = (lengths.length * 3) ~/ 4;

    final keyPoints = {
      lengths.first,  // Min
      lengths[q1Index],  // Q1
      lengths[midIndex], // Median
      lengths[q3Index],  // Q3
      lengths.last,  // Max
    };

    // Pre-calculate max Y value
    final maxY = graphData.map((d) => d.quantity.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;

    // Pre-calculate bar groups
    final barGroups = sortedData.map((data) => BarChartGroupData(
      x: data.length,
      barRods: [
        BarChartRodData(
          toY: data.quantity.toDouble(),
          color: Theme.of(context).primaryColor,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    )).toList();

    // Use RepaintBoundary to optimize rendering
    return RepaintBoundary(
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          barTouchData: BarTouchData(enabled: false),
          maxY: maxY,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (!keyPoints.contains(value.toInt())) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}″',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value != value.roundToDouble()) {
                    return const SizedBox.shrink();
                  }
                  // Format large numbers with K suffix, removing decimal
                  String formattedValue = value >= 1000 
                      ? '${(value / 1000).round()}K'  // Changed to round() instead of toStringAsFixed(1)
                      : value.toInt().toString();
                  return Text(
                    formattedValue,
                    style: const TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }
} 