import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/fish_graph_data.dart';

class FishLengthChart extends StatelessWidget {
  final List<LengthFrequency> frequencies;

  const FishLengthChart({
    super.key,
    required this.frequencies,
  });

  @override
  Widget build(BuildContext context) {
    if (frequencies.isEmpty) {
      return const Center(
        child: Text('No length data available'),
      );
    }

    final sortedFrequencies = List<LengthFrequency>.from(frequencies)
      ..sort((a, b) => a.length.compareTo(b.length));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: sortedFrequencies.map((f) => f.quantity.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= frequencies.length) {
                return null;
              }
              return BarTooltipItem(
                '${frequencies[groupIndex].length}in: ${frequencies[groupIndex].quantity} fish',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= frequencies.length) {
                  return const Text('');
                }
                return Text(
                  '${frequencies[value.toInt()].length}"',
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 30,
            ),
            axisNameWidget: const Text(
              'Length (inches)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
            axisNameWidget: const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: frequencies.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.quantity.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
} 