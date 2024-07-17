import 'dart:math';

import 'package:flutter/material.dart';

class ZoomableChart extends StatefulWidget {
  const ZoomableChart({
    super.key,
    required this.minX,
    required this.maxX,
    required this.builder,
    required this.minPointsToShow,
  });

  final double minX;
  final double maxX;
  final Widget Function(double, double) builder;
  final double minPointsToShow;

  @override
  State<ZoomableChart> createState() => _ZoomableChartState();
}

class _ZoomableChartState extends State<ZoomableChart> {
  late double minX;
  late double maxX;
  late double minPointsToShow;

  late double lastMaxXValue;
  late double lastMinXValue;

  @override
  void initState() {
    super.initState();
    minX = widget.minX;
    maxX = widget.maxX;
    minPointsToShow = widget.minPointsToShow;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          minX = widget.minX;
          maxX = widget.maxX;
        });
      },
      onScaleStart: (details) {
        // minX and maxX correspont to number of datapoints visible
        // (when not x axis by datetime or similar)
        lastMinXValue = minX;
        lastMaxXValue = maxX;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount > 1) {
          var horizontalScale = details.horizontalScale;
          if (horizontalScale == 0) return;

          // get shown distance
          var lastMinMaxDistance = lastMaxXValue - lastMinXValue;
          // scale
          var newMinMaxDistance = lastMinMaxDistance / horizontalScale;
          // get difference
          var distanceDifference = newMinMaxDistance - lastMinMaxDistance;

          // move min and max by difference
          final newMinX = max(lastMinXValue - distanceDifference, 0.0);
          final newMaxX = min(lastMaxXValue + distanceDifference, widget.maxX);

          // prevent scaling to small
          if (newMaxX - newMinX >= minPointsToShow) {
            setState(() {
              minX = newMinX;
              maxX = newMaxX;
            });
          }
        } else {
          var horizontalDistance = details.focalPointDelta.dx;
          if (horizontalDistance == 0) return;
          var lastMinMaxDistance = max(lastMaxXValue - lastMinXValue, 0.0);
          setState(() {
            minX -= lastMinMaxDistance * 0.005 * horizontalDistance;
            maxX -= lastMinMaxDistance * 0.005 * horizontalDistance;

            if (minX < 0) {
              minX = 0;
              maxX = lastMinMaxDistance;
            }
            if (maxX > widget.maxX) {
              maxX = widget.maxX;
              minX = maxX - lastMinMaxDistance;
            }
          });
        }
      },
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text("visible datapoints: ${(maxX - (minX == 0 ? -1 : minX)).toStringAsFixed(0)}"),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: widget.builder(minX, maxX),
          ),
        ],
      ),
    );
  }
}

class ShownRangeCount extends StatelessWidget {
  final String count;

  const ShownRangeCount({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(count),
      ),
    );
  }
}
