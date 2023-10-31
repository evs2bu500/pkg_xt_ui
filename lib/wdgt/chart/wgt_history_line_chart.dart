import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:xt_ui/xt_ui.dart';
import 'package:xt_util/xt_util.dart';

class WgtHistoryLineChart extends StatefulWidget {
  WgtHistoryLineChart({
    Key? key,
    this.titleWidget,
    this.chartRatio = 1.5,
    this.showMaxYValue = false,
    this.showMinYValue = false,
    this.yDecimal,
    this.reservedSizeLeft,
    this.rereservedSizeBottom,
    required this.historyDataSets,
    required this.timeKey,
    required this.valKey,
    this.valUnit,
    this.interval,
    this.xTimeFormat = 'MM-dd HH:mm',
    this.xSpace = 0,
    this.skipInterval,
    this.skipOddXTitle = false,
    this.legend,
    this.minY = 0,
    Color? bottomTextColor,
    Color? bottomTouchedTextColor,
    Color? tooltipTextColor,
  })  : bottomTextColor =
            bottomTextColor ?? AppColors.contentColorYellow.withOpacity(0.62),
        bottomTouchedTextColor =
            bottomTouchedTextColor ?? AppColors.contentColorYellow,
        tooltipTextColor = tooltipTextColor ?? AppColors.contentColorYellow;

  final Widget? titleWidget;
  final double chartRatio;
  // final bool isShowingMainData;
  final String timeKey;
  final String valKey;
  final String? valUnit;
  final List<Map<String, List<Map<String, dynamic>>>> historyDataSets;
  final bool showMaxYValue;
  final bool showMinYValue;
  final int? yDecimal;
  final int? interval;
  final double xSpace;
  final String xTimeFormat;
  final int? skipInterval;
  final bool skipOddXTitle;
  final double? reservedSizeLeft;
  final double? rereservedSizeBottom;
  final Color bottomTextColor;
  final Color bottomTouchedTextColor;
  final Color tooltipTextColor;
  final List<Map<String, dynamic>>? legend;
  final double minY;

  @override
  State<WgtHistoryLineChart> createState() => _WgtHistoryLineChartState();
}

class _WgtHistoryLineChartState extends State<WgtHistoryLineChart> {
  late double touchedValue;

  final bool _fitInsideBottomTitle = false;
  final bool _fitInsideLeftTitle = true;

  List<Map<String, int>> _xTitles = [];

  List<LineChartBarData> _chartDataSets = [];
  int _timeStampStart = 0;
  int _timeStampEnd = 0;
  String _timeFormat = 'HH:mm';
  int _numOfSpots = 0;
  double _maxY = 0;
  // double _minY = 0;
  double _range = 0;

  int _displayDecimal = 2;
  // List<Map<String, dynamic>> _legend = [];

  List<FlSpot> genHistoryChartData(
      List<Map<String, dynamic>> historyData, String timeKey, String valKey,
      {List<Map<String, dynamic>>? errorData}) {
    List<FlSpot> chartData = [];
    Map<String, dynamic> firstData = historyData.first;
    bool isDouble = firstData[valKey] is double;
    for (var historyDataItem in historyData) {
      int timestamp =
          DateTime.parse(historyDataItem[timeKey]).millisecondsSinceEpoch;
      double value = isDouble
          ? historyDataItem[valKey]
          : double.parse(historyDataItem[valKey]);
      if (value > _maxY) {
        _maxY = value;
      }
      chartData.add(FlSpot(timestamp.toDouble(), value));
      if (errorData != null) {
        if (historyDataItem['error_data'] != null) {
          errorData.add({timestamp.toString(): historyDataItem['error_data']});
        }
      }
    }
    return chartData;
  }

  Widget leftTitles(double value, TitleMeta meta) {
    double max = meta.max;
    if (!widget.showMaxYValue) {
      if (value > 0.999 * max) {
        return Container();
      }
    }
    if (!widget.showMinYValue) {
      if (value < 1.001 * meta.min) {
        return Container();
      }
    }
    final style = TextStyle(
      color: widget.bottomTextColor,
      fontSize: 13,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      fitInside: _fitInsideLeftTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta)
          : SideTitleFitInsideData.disable(),
      child: Text(
          // text,
          // yTitles[index],
          value.toStringAsFixed(_displayDecimal),
          style: style,
          textAlign: TextAlign.center),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final isTouched = value == touchedValue;
    final style = TextStyle(
      color: isTouched ? widget.bottomTouchedTextColor : widget.bottomTextColor,
      fontSize: 13,
    );

    if (value.toInt() == _timeStampStart || value.toInt() == _timeStampEnd) {
      return Container();
    }
    double hideEdge = 0.05;
    int range = _timeStampStart - _timeStampEnd;
    int margin = (range * hideEdge).toInt();
    if (value < _timeStampEnd + margin || value > _timeStampStart - margin) {
      return Container();
    }

    //find the index of the value in the xTitles
    int index = -1;
    for (var i = 0; i < _xTitles.length; i++) {
      if (double.parse(_xTitles[i].keys.first).toInt() == value.toInt()) {
        index = i;
        break;
      }
    }
    if (widget.skipInterval != null) {
      if (widget.skipInterval! > 2) {
        if (index > 0 && index % widget.skipInterval! != 0) {
          return Container();
        }
      }
    } else {
      if (index > 0 && (widget.skipOddXTitle) && index % 2 == 1) {
        return Container();
      }
    }

    // String xTitle = "";
    // xTitle = getDateTimeStrFromTimestamp(value.toInt(), format: _timeFormat);
    String xTitle = getDateFromDateTimeStr(
        DateTime.fromMillisecondsSinceEpoch(value.toInt()).toString(),
        format: widget.xTimeFormat);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: _fitInsideBottomTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0)
          : SideTitleFitInsideData.disable(),
      // space: 30,
      // angle: 4 * pi / 12,
      // child: Text(
      //   xTitle,
      //   style: style,
      // ),
      // angle: 4 * pi / 12,
      child: Transform.translate(
        offset: Offset(0, widget.xSpace),
        child: Transform.rotate(
          angle: 4 * pi / 12,
          child: Text(
            xTitle, // xTitles[value.toInt()],
            style: style,
          ),
        ),
      ),
    );
  }

  List<LineTooltipItem?> getToolTipItems(List<LineBarSpot> touchedBarSpots) {
    List<double> yValues = [];
    for (var tbs in touchedBarSpots) {
      yValues.add(tbs.y);
    }
    double yMin = yValues.reduce(min);
    return touchedBarSpots.map((barSpot) {
      final flSpot = barSpot;
      // if (flSpot.x == 0 || flSpot.x == 6) {
      //   return null;
      // }

      TextAlign textAlign;
      switch (flSpot.x.toInt()) {
        case 1:
          textAlign = TextAlign.left;
          break;
        case 5:
          textAlign = TextAlign.right;
          break;
        default:
          textAlign = TextAlign.center;
      }

      Color? textColor;
      if (widget.legend != null) {
        textColor = widget.legend![barSpot.barIndex]['color'];
      }
      // bool sapceSaveer = true;
      // barSpot.barIndex > 0 || touchedBarSpots.length == 1;
      bool singleTimestampLabel = true;
      // print('${barSpot.barIndex} ${touchedBarSpots.length}');

      //find the barSpot.barIndex of barSpot with the smallest y value
      // int minIndex = 0;
      // double min = touchedBarSpots[0].y;
      // for (var i = 1; i < touchedBarSpots.length; i++) {
      //   if (touchedBarSpots[i].y < min) {
      //     min = touchedBarSpots[i].y;
      //     minIndex = i;
      //   }
      // }
      // String yvalue = '';

      // print('${barSpot.barIndex} $minIndex $yvalue');

      bool showTimestamp =
          (singleTimestampLabel && barSpot.y <= yMin) || !singleTimestampLabel;
      return LineTooltipItem(
        // '${flSpot.y.toInt()}${widget.valUnit ?? ''}${sapceSaveer ? '\n' : ''}',
        '${flSpot.y.toStringAsFixed(widget.yDecimal ?? 0)}${widget.valUnit ?? ''}${showTimestamp ? '\n' : ''}',
        TextStyle(
          color: textColor ?? widget.tooltipTextColor,
          fontWeight: FontWeight.bold,
        ),
        children:
            //  [
            //   TextSpan(
            //     text: getDateTimeStrFromTimestamp(flSpot.x.toInt(),
            //         format: _timeFormat),
            //     style: TextStyle(
            //       color: widget.tooltipTextColor,
            //       fontWeight: FontWeight.w300,
            //     ),
            //   )
            // ],

            // sapceSaveer
            //     ? [
            //         TextSpan(
            //           text: getDateTimeStrFromTimestamp(flSpot.x.toInt(),
            //               format: _timeFormat),
            //           style: TextStyle(
            //             color: widget.tooltipTextColor,
            //             fontWeight: FontWeight.w300,
            //           ),
            //         )
            //       ]
            //     : [],

            showTimestamp
                ? [
                    TextSpan(
                      text: getDateTimeStrFromTimestamp(flSpot.x.toInt(),
                          format: _timeFormat),
                      style: TextStyle(
                        color: widget.tooltipTextColor,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  ]
                : [],

        textAlign: textAlign,
      );
    }).toList();
  }

  void _genChartData() {
    _chartDataSets = [];

    _maxY = 0;
    _timeStampStart = 0;
    _timeStampEnd = 0;
    int i = 0;
    for (var historyDataInfo in widget.historyDataSets) {
      Color? lineColor;
      if (widget.legend != null) {
        for (var legendItem in widget.legend!) {
          if (legendItem['name'] == historyDataInfo.keys.first) {
            lineColor = legendItem['color'];
          }
        }
      }

      for (List<Map<String, dynamic>> historyData
          in historyDataInfo.values.toList()) {
        _numOfSpots = historyData.length;
        Color color = lineColor ??
            AppColors.tier1colorsAlt[i > 8 ? 8 : i].withOpacity(0.8);
        // AppColors.getColorListBlueGreen()[i > 8 ? 8 : i].withOpacity(0.8);

        i++;
        List<FlSpot> chartData = genHistoryChartData(
            historyData, widget.timeKey, widget.valKey,
            errorData: []);
        _timeStampStart = chartData.first.x.toInt();
        _timeStampEnd = chartData.last.x.toInt();
        _timeFormat = getDateTimeFormat(
            (_timeStampStart - _timeStampEnd).abs() ~/ msPerMinute);

        //building xTitles
        _xTitles = [];
        int dataLength = chartData.length;
        for (var i = 0; i < dataLength; i++) {
          _xTitles.add(Map.of({chartData[i].x.toString(): 0}));
        }

        _chartDataSets.add(LineChartBarData(
          isCurved: false,
          color: color,
          barWidth: 1.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: false,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 2,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: color,
                );
              }),
          belowBarData: BarAreaData(show: false),
          spots: chartData,
        ));
      }
    }
    _range = _maxY - widget.minY;
    if (_range == 0) {
      _range = 0.1 * widget.minY;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _genChartData();

    _displayDecimal = widget.yDecimal ?? decideDisplayDecimal(_maxY);
    touchedValue = -1;
    return AspectRatio(
      aspectRatio: widget.chartRatio,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.titleWidget ?? Container(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: LineChart(
                    LineChartData(
                      minY: widget.minY - 0.5 * _range > 0
                          ? widget.minY - 0.5 * _range
                          : 0,
                      maxY: _maxY + 0.34 * _range,
                      lineBarsData: _chartDataSets,
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: widget.reservedSizeLeft ?? 40,
                            getTitlesWidget: leftTitles,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: widget.rereservedSizeBottom ?? 55,
                            interval: 5 *
                                msPerMinute *
                                ((_timeStampEnd - _timeStampStart).abs() /
                                        msPerHour)
                                    .toDouble(),
                            getTitlesWidget: bottomTitles,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                              color: AppColors.primary.withOpacity(0.33),
                              width: 2),
                          left: const BorderSide(color: Colors.transparent),
                          right: const BorderSide(color: Colors.transparent),
                          top: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        // enabled: true,
                        handleBuiltInTouches: true,
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            final flSpot = barData.spots[spotIndex];
                            if (flSpot.x == 0 || flSpot.x == 6) {
                              return null;
                            }
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: Colors.blueGrey.withOpacity(0.8),
                                strokeWidth: 2,
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withOpacity(0.5),
                                    strokeWidth: 2,
                                    strokeColor:
                                        Colors.blueGrey.withOpacity(0.8),
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 2,
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          getTooltipItems: getToolTipItems,
                        ),
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? lineTouch) {
                          if (!event.isInterestedForInteractions ||
                              lineTouch == null ||
                              lineTouch.lineBarSpots == null) {
                            setState(() {
                              touchedValue = -1;
                            });
                            return;
                          }
                          final value = lineTouch.lineBarSpots![0].x;

                          if (value == 0 || value == 6) {
                            setState(() {
                              touchedValue = -1;
                            });
                            return;
                          }

                          setState(() {
                            touchedValue = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getDateTimeFormat(int timeRangeInMinute) {
    String format = 'YYYY-MM-dd HH:mm:ss';
    if (timeRangeInMinute <= 60) {
      return 'HH:mm:ss';
    } else if (timeRangeInMinute <= 60 * 24) {
      return 'HH:mm';
    } else if (timeRangeInMinute <= 60 * 24 * 7) {
      return 'MM-dd HH:mm';
    } else if (timeRangeInMinute <= 60 * 24 * 30) {
      return 'MM-dd';
    } else if (timeRangeInMinute <= 60 * 24 * 365) {
      return 'YYYY-MM-dd';
    } else {
      return format;
    }
  }
}
