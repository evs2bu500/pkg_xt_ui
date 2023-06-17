import 'dart:math';

import 'package:xt_util/xt_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../style/app_colors.dart';

class WgtHistoryBarChart extends StatefulWidget {
  WgtHistoryBarChart({
    Key? key,
    Color? barColor,
    Color? tooltipTextColor,
    Color? tooltipBackgroundColor,
    Color? errorTooltipBackgroundColor,
    Color? highlightColor,
    Color? bottomTextColor,
    Color? bottomTouchedTextColor,
    this.border,
    this.reservedSizeLeft,
    this.rereservedSizeBottom,
    this.tooltipTimeFormat,
    // this.width,
    this.ratio,
    this.title,
    this.showTitle = true,
    this.titleWidget,
    this.yUnit = '',
    this.toolTipDecimal,
    this.showMaxYValue = false,
    required this.historyData,
    required this.timeKey,
    required this.valKey,
    required this.dominantInterval,
    required this.yDecimal,
  })  : barColor = barColor ?? AppColors.contentColorYellow,
        tooltipTextColor = tooltipTextColor ?? AppColors.contentColorYellow,
        tooltipBackgroundColor = tooltipBackgroundColor ??
            AppColors.contentColorYellow.withOpacity(0.62),
        errorTooltipBackgroundColor =
            errorTooltipBackgroundColor ?? Colors.redAccent.withOpacity(0.62),
        highlightColor = highlightColor ?? AppColors.contentColorYellow,
        bottomTextColor =
            bottomTextColor ?? AppColors.contentColorYellow.withOpacity(0.62),
        bottomTouchedTextColor =
            bottomTouchedTextColor ?? AppColors.contentColorYellow;

  final List<Map<String, dynamic>> historyData;
  final String timeKey;
  final String valKey;
  final int dominantInterval;
  final int yDecimal;
  final String yUnit;
  final int? toolTipDecimal;
  final bool showMaxYValue;
  final String? title;
  final bool showTitle;
  final Widget? titleWidget;
  // final double? width;
  final double? reservedSizeLeft;
  final double? rereservedSizeBottom;
  final double? ratio;
  final Color barColor;
  final Color tooltipTextColor;
  final Color tooltipBackgroundColor;
  final Color errorTooltipBackgroundColor;
  final Color highlightColor;
  final Color bottomTextColor;
  final Color bottomTouchedTextColor;
  final Border? border;
  final String? tooltipTimeFormat;

  @override
  _WgtHistoryBarChartState createState() => _WgtHistoryBarChartState();
}

class _WgtHistoryBarChartState extends State<WgtHistoryBarChart> {
  late double _touchedValue;

  final Duration animDuration = const Duration(milliseconds: 200);

  bool fitInsideBottomTitle = true;
  bool fitInsideLeftTitle = false;

  bool _errorToolTip = false;

  //check the max value of the list
  // List<Map<String, int>> _xTitles = [];
  // int _xDominantInterval = 0;
  // double _xInterval = 0;
  // int _xTitleCount = 8;
  // int _xSpan = 0;
  // int _xTitleInterval = 0;

  int dataLength = 0;
  double _maxY = 0;
  double _yGridFactor = 1;
  // List<String> _yTitles = [];
  int yAxisTitleCount = 5;
  // int _prevYAxisTitleIndex = -1;
  int _timeStampStart = 0;
  int _timeStampEnd = 0;

  // late double _chartWidth;
  // double _rodSpace = 5;
  double _barWidth = 10;
  List<BarChartGroupData> _barGroups = [];

  List<FlSpot> _chartData = [];
  List<Map<String, dynamic>> _errorData = [];

  Widget leftTitles(double value, TitleMeta meta) {
    double max = meta.max;
    if (!widget.showMaxYValue) {
      if (value > 0.999 * max) {
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
      fitInside: fitInsideLeftTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta)
          : SideTitleFitInsideData.disable(),
      child: Text(
          // text,
          // yTitles[index],
          value.toStringAsFixed(widget.yDecimal),
          style: style,
          textAlign: TextAlign.center),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final isTouched = value == _touchedValue;
    final style = TextStyle(
      color: isTouched ? widget.bottomTouchedTextColor : widget.bottomTextColor,
      // fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    if (value.toInt() ==
        _timeStampStart /* || value.toInt() == _timeStampEnd*/) {
      return Container();
    }

    String xTitle = "";
    //check if the value is present in the xTitles as a value
    // for (Map<String, int> titleTime in _xTitles) {
    //   if (titleTime.values.first == value.toInt()) {
    //     xTitle = getDateFromDateTimeStr(titleTime.keys.first, format: "MM-dd");
    //     break;
    //   }
    // }
    xTitle = getDateFromDateTimeStr(
        DateTime.fromMillisecondsSinceEpoch(value.toInt()).toString(),
        format: "MM-dd");

    return SideTitleWidget(
      space: 16,
      axisSide: meta.axisSide,
      fitInside: fitInsideBottomTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0)
          : SideTitleFitInsideData.disable(),
      angle: 4 * pi / 12,
      child: Text(
        xTitle, // xTitles[value.toInt()],
        style: style,
      ),
    );
  }

  List<BarChartGroupData> getBars(int touchedValue) {
    // Color barColor = widget.barColor.withOpacity(0.62);
    // double rodWidth = 0.92 * _chartWidth / dataLength;
    // _rodSpace = 0.08 * _chartWidth / dataLength;
    return [
      for (var i = dataLength - 1; i >= 0; i--)
        BarChartGroupData(
          x: _chartData[i].x.toInt(),
          // barsSpace: _rodSpace,
          barRods: [
            BarChartRodData(
              toY: _chartData[i].y,
              width: _barWidth, //rodWidth,
              color: setBarColor(i, touchedValue),
              borderRadius: BorderRadius.circular(3),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _maxY,
                color: Colors.transparent,
              ),
            ),
          ],
          // showingTooltipIndicators: [0],
        ),
    ];
  }

  Color? setBarColor(int i, int touchedValue) {
    if (i == dataLength - touchedValue - 1) {
      return widget.tooltipBackgroundColor;
      // return widget.highlightColor; //Colors.white;
    }

    return widget.barColor.withOpacity(0.62);
  }

  @override
  void initState() {
    super.initState();

    _chartData = genHistoryChartData(
        widget.historyData, widget.timeKey, widget.valKey,
        errorData: _errorData);

    // _chartWidth = widget.width ?? 900; //0.8 * MediaQuery.of(context).size.width;

    dataLength = _chartData.length;
    //normalize the data
    List<double> yValues = [];
    for (var i = 0; i < dataLength; i++) {
      yValues.add(double.parse(widget.historyData[i][widget.valKey]));
    }
    _maxY = findMax(yValues);

    //_maxY = 0.3, _yGridFactor = 10, _maxY = 0.03, _yGridFactor = 100
    _yGridFactor = 1;
    if (_maxY > 0.1) {
      _yGridFactor = 10;
    }
    if (_maxY > 1) {
      _yGridFactor = 100;
    }
    if (_maxY > 10) {
      _yGridFactor = 1000;
    }
    if (_maxY > 100) {
      _yGridFactor = 10000;
    }
    if (_maxY > 1000) {
      _yGridFactor = 100000;
    }

    _timeStampEnd = _chartData[0].x.toInt();
    _timeStampStart = _chartData[dataLength - 1].x.toInt();

    //calculate the interval between two x axis titles
    // int xIntervalHalfHours = 2;
    // if (dataLength > 24) {
    //   xIntervalHalfHours = (dataLength / 12).round();
    // }
    // _xInterval = xIntervalHalfHours * widget.dominantInterval.toDouble();

    // _xTitleCount = 8;
    // _xSpan = _timeStampEnd - _timeStampStart;
    // _xTitleInterval = (_xSpan / _xTitleCount).round();
    // for (var i = 0; i < _xTitleCount; i++) {
    //   int xTitleTimeStamp = _timeStampStart + _xTitleInterval * i;
    //   final dateTime = DateTime.fromMillisecondsSinceEpoch(xTitleTimeStamp);
    //   int hour = dateTime.hour;
    //   int minute = dateTime.minute;
    //   String xTitle = "";

    //   //check if the minute is close to 0 or 30
    //   if (minute < 15) {
    //     minute = 0;
    //   } else if (minute < 45) {
    //     minute = 30;
    //   } else {
    //     minute = 0;
    //     hour += 1;
    //   }
    //   DateTime roundedDateTime = DateTime(
    //     dateTime.year,
    //     dateTime.month,
    //     dateTime.day,
    //     hour,
    //     minute,
    //   );

    //   xTitle = dateFormat.format(roundedDateTime);

    //if the xTitle is the same as the previous one, skip it
    //   if (xTitles.isNotEmpty && xTitle == xTitles[xTitles.length - 1]) {
    //     continue;
    //   }
    //   xTitles.add(Map.of({xTitle: 0}));
    // }

    //find the reading timestamp that is closest to the xTitle
    // for (Map<String, int> xTitle in xTitles) {
    //   int xTitleTimeStamp =
    //       dateFormat.parse(xTitle.keys.first).millisecondsSinceEpoch;

    //   for (int i = 0; i < dataLength - 1; i++) {
    //     int nextTimeStamp = _chartData[i].x.toInt();
    //     int prevTimeStamp = _chartData[i + 1].x.toInt();

    //     if (xTitleTimeStamp >= prevTimeStamp &&
    //         xTitleTimeStamp <= nextTimeStamp) {
    //       double gapPre = (xTitleTimeStamp - prevTimeStamp).abs().toDouble();
    //       double gapNext = (xTitleTimeStamp - nextTimeStamp).abs().toDouble();
    //       if (gapPre < gapNext) {
    //         xTitle.update(xTitle.keys.first, (value) => prevTimeStamp);
    //       } else {
    //         xTitle.update(xTitle.keys.first, (value) => nextTimeStamp);
    //       }
    //       break;
    //     }
    //   }
    // }

    // _barGroups = getBars(-1);

    // _containHighlight = false;
    // _highlightedBarGroups = getData(0);

    _touchedValue = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTitle)
          widget.titleWidget ??
              Text(
                widget.title ?? '',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        AspectRatio(
          aspectRatio: widget.ratio ?? 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 12),
            child: LayoutBuilder(builder: (context, constraints) {
              final barsSpace = 0.08 * constraints.maxWidth / dataLength;
              final wAdj = widget.reservedSizeLeft == null
                  ? 0
                  : widget.reservedSizeLeft! - 21;
              final barsWidth =
                  0.85 * (constraints.maxWidth - wAdj) / dataLength;

              _barWidth = barsWidth;
              _barGroups = getBars(_touchedValue.toInt());

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  groupsSpace: barsSpace, //_rodSpace,
                  barGroups: _barGroups,
                  //getData(barsWidth, barsSpace, -1),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedValue = -1;
                        setState(() {
                          // _containHighlight = false;
                          _barGroups = getBars(-1);
                        });
                        return;
                      }
                      _touchedValue = barTouchResponse
                          .spot!.touchedBarGroupIndex
                          .toDouble();

                      setState(() {
                        // _containHighlight = true;
                        _barGroups = getBars(_touchedValue.toInt());
                      });
                      // print('touch');
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: _errorToolTip
                          ? widget.errorTooltipBackgroundColor
                          : widget.tooltipBackgroundColor,
                      tooltipPadding: const EdgeInsets.all(3),
                      tooltipMargin: 6,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        // setState(() {
                        //   _errorToolTip = false;
                        // });

                        String errorDataText = '';
                        if (_errorData.isNotEmpty) {
                          // errorDataText = _errorData[rodIndex].values.first;
                          String key = group.x.toInt().toString();
                          Map<String, dynamic> errorData =
                              getElementMapByKey(_errorData, key);
                          if (errorData.isNotEmpty) {
                            errorDataText = errorData[key];
                            if (errorDataText.isNotEmpty) {
                              // setState(() {
                              _errorToolTip = true;
                              // });
                            }
                          }
                        }

                        final timeText = getDateFromDateTimeStr(
                            DateTime.fromMicrosecondsSinceEpoch(
                                    group.x.toInt() * 1000)
                                .toString(),
                            format: widget.tooltipTimeFormat ?? 'MM-dd HH:mm');

                        String yText = rod.toY.toStringAsFixed(
                            widget.toolTipDecimal ?? widget.yDecimal);
                        return BarTooltipItem(
                          errorDataText.isEmpty
                              ? '$yText${widget.yUnit}'
                              : 'Error Data: $errorDataText',
                          errorDataText.isEmpty
                              ? TextStyle(
                                  color: widget.tooltipTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)
                              : TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                          children: [
                            TextSpan(
                              text: ' $timeText',
                              style: TextStyle(
                                color: widget.tooltipTextColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                // fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
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
                        reservedSize: widget.rereservedSizeBottom ?? 40,
                        getTitlesWidget: bottomTitles,
                        interval: -5, //_xInterval * 1,
                      ),
                    ),
                  ),
                  minY: 0,
                  borderData: FlBorderData(
                    show: true,
                    border: widget.border ??
                        Border.all(
                          // color: AppColors.borderColor,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.33),
                        ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    checkToShowHorizontalLine: (value) =>
                        value * _yGridFactor % 1 == 0,
                    checkToShowVerticalLine: (value) => value % 1 == 0,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        return const FlLine(
                          color: AppColors.contentColorOrange,
                          strokeWidth: 2,
                        );
                      } else {
                        return FlLine(
                          color: Theme.of(context)
                              .hintColor
                              .withOpacity(0.2), //AppColors.mainGridLineColor,
                          strokeWidth: 0.5,
                        );
                      }
                    },
                    getDrawingVerticalLine: (value) {
                      if (value == 0) {
                        return const FlLine(
                          color: Colors.redAccent,
                          strokeWidth: 10,
                        );
                      } else {
                        return const FlLine(
                          color: AppColors.mainGridLineColor,
                          strokeWidth: 0.5,
                        );
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

List<FlSpot> genHistoryChartData(
    List<Map<String, dynamic>> historyData, String timeKey, String valKey,
    {List<Map<String, dynamic>>? errorData}) {
  List<FlSpot> chartData = [];

  for (var historyDataItem in historyData) {
    int timestamp =
        DateTime.parse(historyDataItem[timeKey]).millisecondsSinceEpoch;
    chartData.add(
        FlSpot(timestamp.toDouble(), double.parse(historyDataItem[valKey])));
    if (errorData != null) {
      if (historyDataItem['error_data'] != null) {
        errorData.add({timestamp.toString(): historyDataItem['error_data']});
      }
    }
  }
  return chartData;
}
