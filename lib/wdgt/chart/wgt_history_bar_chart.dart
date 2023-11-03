import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:xt_util/xt_util.dart';
import '../../style/app_colors.dart';

class WgtHistoryBarChart extends StatefulWidget {
  WgtHistoryBarChart({
    super.key,
    // Key? key,
    Color? barColor,
    Color? tooltipTextColor,
    Color? tooltipBackgroundColor,
    Color? errorTooltipBackgroundColor,
    Color? highlightColor,
    Color? bottomTextColor,
    Color? bottomTouchedTextColor,
    this.chartKey,
    this.border,
    this.reservedSizeLeft,
    this.rereservedSizeBottom,
    this.tooltipTimeFormat,
    this.xTimeFormat = 'MM-dd HH:mm',
    this.xSpace = 8,
    this.skipOddXTitle = false,
    this.skipInterval,
    this.ratio,
    this.title,
    this.showTitle = true,
    this.titleWidget,
    this.yUnit = '',
    this.maxVal,
    this.showKonY,
    this.showEmptyMessage,
    this.toolTipDecimal,
    this.showMaxYValue = false,
    required this.historyData,
    required this.timeKey,
    required this.valKey,
    this.dominantIntervalSecond,
    this.altBarTip,
    this.altBarTipKey,
    this.altBarTipIf,
    this.useAltBarColor,
    this.altBarColorIf,
    this.prefixLabelIf,
    this.prefixLabel,
    required this.yDecimal,
    this.showXTitle = true,
    this.showYTitle = true,
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
  final int? dominantIntervalSecond;
  final int yDecimal;
  final String yUnit;
  final double? maxVal;
  final bool? showKonY;
  final bool? showEmptyMessage;
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
  final String xTimeFormat;
  final double xSpace;
  final bool skipOddXTitle;
  final int? skipInterval;
  final String? altBarTipKey;
  final String? altBarTip;
  final Function? altBarTipIf;
  final bool? useAltBarColor;
  final Function? altBarColorIf;
  final Function? prefixLabelIf;
  final String? prefixLabel;
  final UniqueKey? chartKey;
  final bool showXTitle;
  final bool showYTitle;

  @override
  _WgtHistoryBarChartState createState() => _WgtHistoryBarChartState();
}

class _WgtHistoryBarChartState extends State<WgtHistoryBarChart> {
  UniqueKey? _chartKey;
  late double _touchedValue;

  final Duration animDuration = const Duration(milliseconds: 200);

  bool fitInsideBottomTitle = false;
  bool fitInsideLeftTitle = false;

  bool _errorToolTip = false;

  //check the max value of the list
  List<Map<String, int>> _xTitles = [];
  // int _xDominantInterval = 0;
  // double _xInterval = 0;
  // int _xTitleCount = 8;
  // int _xSpan = 0;
  // int _xTitleInterval = 0;

  int dataLength = 0;
  double _maxX = 0;
  double _xInterval = 1;
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
  List<Map<String, dynamic>> _altBarTipData = [];
  bool _valueIsDouble = false;

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
          // value.toStringAsFixed(widget.yDecimal),
          widget.showKonY != null
              ? widget.showKonY!
                  ? getK(value)
                  : value.toStringAsFixed(widget.yDecimal)
              : value.toStringAsFixed(widget.yDecimal),
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

    if (value.toInt() == _timeStampStart || value.toInt() == _timeStampEnd) {
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
    //check if the value is present in the xTitles as a value
    // for (Map<String, int> titleTime in _xTitles) {
    //   if (titleTime.values.first == value.toInt()) {
    //     xTitle = getDateFromDateTimeStr(titleTime.keys.first, format: "MM-dd");
    //     break;
    //   }
    // }
    String xTitle = getDateFromDateTimeStr(
        DateTime.fromMillisecondsSinceEpoch(value.toInt()).toString(),
        format: widget.xTimeFormat);

    return SideTitleWidget(
      space: 0,
      axisSide: meta.axisSide,
      fitInside: fitInsideBottomTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0)
          : SideTitleFitInsideData.disable(),
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

  List<FlSpot> genHistoryChartData(
      List<Map<String, dynamic>> historyData, String timeKey, String valKey,
      {List<Map<String, dynamic>>? errorData,
      List<Map<String, dynamic>>? altBarTipData}) {
    List<FlSpot> chartData = [];
    _valueIsDouble = historyData[0][valKey] is double;
    for (var historyDataItem in historyData) {
      int timestamp =
          DateTime.parse(historyDataItem[timeKey]).millisecondsSinceEpoch;
      chartData.add(FlSpot(
          timestamp.toDouble(),
          _valueIsDouble
              ? historyDataItem[valKey]
              : double.parse(historyDataItem[valKey])));
      if (errorData != null) {
        if (historyDataItem['error_data'] != null) {
          errorData.add({timestamp.toString(): historyDataItem['error_data']});
        }
      }
      if (altBarTipData != null && widget.altBarTipKey != null) {
        if (historyDataItem[widget.altBarTipKey] != null) {
          altBarTipData.add(
              {timestamp.toString(): historyDataItem[widget.altBarTipKey]});
        }
      }
    }
    return chartData;
  }

  Color? setBarColor(int i, int touchedValue) {
    if (widget.altBarColorIf != null) {
      if (widget.altBarColorIf!(i, widget.historyData[i])) {
        return widget.barColor.withOpacity(0.5);
      }
    }

    if (i == dataLength - touchedValue - 1) {
      return widget.tooltipBackgroundColor;
      // return widget.highlightColor; //Colors.white;
    }
    Color barColor = widget.barColor.withOpacity(0.67);

    return widget.useAltBarColor ?? false
        ? widget.altBarTipIf != null
            ? widget.altBarTipIf!(_altBarTipData[i].values.first)
                ? widget.barColor.withOpacity(0.5)
                : barColor
            : barColor
        : barColor;
  }

  void _loadChartData() {
    _chartData = genHistoryChartData(
        widget.historyData, widget.timeKey, widget.valKey,
        errorData: _errorData, altBarTipData: _altBarTipData);

    // _chartWidth = widget.width ?? 900; //0.8 * MediaQuery.of(context).size.width;

    dataLength = _chartData.length;
    //normalize the data
    List<double> yValues = [];

    for (var i = 0; i < dataLength; i++) {
      yValues.add(_valueIsDouble
          ? widget.historyData[i][widget.valKey]
          : double.parse(widget.historyData[i][widget.valKey]));
    }
    _maxY = findMax(yValues);
    //_maxY = 0.3, _yGridFactor = 10, _maxY = 0.03, _yGridFactor = 100
    _yGridFactor = 1;
    if (_maxY > 0.1) {
      _yGridFactor = 10;
    } else if (_maxY > 0.01) {
      _yGridFactor = 100;
    } else if (_maxY > 0.001) {
      _yGridFactor = 1000;
    } else if (_maxY > 0.0001) {
      _yGridFactor = 10000;
    } else if (_maxY > 0.00001) {
      _yGridFactor = 100000;
    }

    _timeStampEnd = _chartData[0].x.toInt();
    _timeStampStart = _chartData[dataLength - 1].x.toInt();

    //building xTitles
    _xTitles = [];
    for (var i = 0; i < dataLength; i++) {
      _xTitles.add(Map.of({_chartData[i].x.toString(): 0}));
    }
    _touchedValue = -1;
  }

  @override
  void initState() {
    super.initState();

    _loadChartData();
    _chartKey = widget.chartKey;
  }

  @override
  Widget build(BuildContext context) {
    // give the bar chart a new key to
    // reload the chart with new data
    if (widget.chartKey != null) {
      if (_chartKey != widget.chartKey) {
        _chartKey = widget.chartKey;
        _loadChartData();
      }
    }
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
              // print(widget.key);
              return Stack(
                children: [
                  if (widget.maxVal == 0 && widget.showEmptyMessage == true)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 89.0),
                        child: Text(
                          'zero values for the duration',
                          style: TextStyle(
                              fontSize: getMaxFitFontSize(
                                  constraints.maxWidth * 0.75,
                                  'zero values for the duration',
                                  const TextStyle(fontWeight: FontWeight.bold)),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .hintColor
                                  .withOpacity(0.13)),
                        ),
                      ),
                    ),
                  BarChart(
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
                          setState(() {
                            _touchedValue = barTouchResponse
                                .spot!.touchedBarGroupIndex
                                .toDouble();
                          });

                          // setState(() {
                          // _containHighlight = true;
                          // _barGroups = getBars(_touchedValue.toInt());
                          // });
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
                            String altBarTipValue = '';
                            if (_altBarTipData.isNotEmpty) {
                              String key = group.x.toInt().toString();
                              Map<String, dynamic> altBarTip =
                                  getElementMapByKey(_altBarTipData, key);
                              if (altBarTip.isNotEmpty) {
                                altBarTipValue = altBarTip[key];
                              }
                            }

                            final timeText = getDateFromDateTimeStr(
                                DateTime.fromMicrosecondsSinceEpoch(
                                        group.x.toInt() * 1000)
                                    .toString(),
                                format:
                                    widget.tooltipTimeFormat ?? 'MM-dd HH:mm');

                            String yText = rod.toY.toStringAsFixed(
                                widget.toolTipDecimal ?? widget.yDecimal);

                            if (widget.prefixLabelIf != null) {
                              // String key = group.x.toInt().toString();
                              int index = _chartData.indexWhere((element) =>
                                  element.x.toInt() == group.x.toInt());
                              if (index != -1) {
                                if (widget.prefixLabelIf!(
                                    index, widget.historyData[index])) {
                                  yText = '${widget.prefixLabel ?? ''}$yText';
                                }
                              }
                            }

                            return BarTooltipItem(
                              errorDataText.isNotEmpty
                                  ? 'Error Data: $errorDataText'
                                  : altBarTipValue.isNotEmpty
                                      ? widget.altBarTipIf != null
                                          ? widget.altBarTipIf!(altBarTipValue)
                                              ? widget.altBarTip ?? ''
                                              : '$yText${widget.yUnit}'
                                          : '$yText${widget.yUnit}'
                                      : '$yText${widget.yUnit}',
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
                            showTitles: widget.showYTitle,
                            reservedSize: widget.reservedSizeLeft ?? 40,
                            getTitlesWidget: leftTitles,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: widget.showXTitle,
                            reservedSize: widget.rereservedSizeBottom ?? 40,
                            getTitlesWidget: bottomTitles,
                            // for bar chart, maxX is hard coded to 1
                            // interval is ignored
                            interval: 1,
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
                              color: Theme.of(context).hintColor.withOpacity(
                                  0.2), //AppColors.mainGridLineColor,
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
                    // key: UniqueKey(),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
