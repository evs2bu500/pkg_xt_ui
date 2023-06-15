import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'dart:ui';

Map<String, dynamic> getElementMapByKey(
    List<Map<String, dynamic>> listOfMaps, String key) {
  Map<String, dynamic> foundMap = listOfMaps
      // .firstWhere((map) => map[keyName] == keyValue, orElse: () => {});
      .firstWhere((element) => element.containsKey(key), orElse: () => {});
  return foundMap;
}

Map<String, dynamic> getElementMapByValue(
    List<Map<String, dynamic>> listOfMaps, String keyName, String keyValue) {
  Map<String, dynamic> foundMap = listOfMaps
      .firstWhere((map) => map[keyName] == keyValue, orElse: () => {});

  return foundMap;
}

double findMax(List<double> list) {
  double max = 0;
  for (double item in list) {
    if (item > max) {
      max = item;
    }
  }
  return max;
}

bool isBetween(double value, double min, double max) {
  return value.compareTo(min) >= 0 && value.compareTo(max) <= 0;
}

Size getSafeSize(context) {
  var padding = MediaQuery.of(context).padding;
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  double safeHeight = height - padding.top - padding.bottom;
  return Size(width, safeHeight);
}

bool isJwtToken(String token) {
  RegExp jwtPattern =
      RegExp(r'^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$');
  return jwtPattern.hasMatch(token);
}

String explainException(Object e) {
  String msg = '';
  String errorMessage = e.toString();
  if (errorMessage.toLowerCase().contains('device') &&
      errorMessage.toLowerCase().contains('not online')) {
    msg = 'device not online';
  }
  if (errorMessage.toLowerCase().contains('no ') &&
      errorMessage.toLowerCase().contains('permission')) {
    msg = 'no permission';
  }
  if (errorMessage.toLowerCase().contains('remote computer') &&
      errorMessage.toLowerCase().contains('refused')) {
    msg = 'server not available';
  }
  if (errorMessage.toLowerCase().contains('unable to connect') &&
      errorMessage.toLowerCase().contains('authentication')) {
    msg = 'authentication server not available';
  }
  if (errorMessage.toLowerCase().contains('internal server') &&
      errorMessage.toLowerCase().contains('error')) {
    msg = 'service error';
  }
  if (errorMessage.toLowerCase().contains('not authorized') &&
      errorMessage.toLowerCase().contains('perform this operation')) {
    msg = 'permission not authorized';
  }

  return msg;
}

String makeReportName(
    String prefix, String? targetSpec, DateTime? start, DateTime? end) {
  String reportName = '';
  //suffix: get currrent datetime
  String suffix = DateFormat('MMddHHmmss').format(DateTime.now());
  String targetSpecSec =
      targetSpec == null || targetSpec.isEmpty ? '' : '_$targetSpec';
  String startSec =
      start == null ? '' : '_${start.year}${start.month}${start.day}';
  String endSec = end == null ? '' : '_${end.year}${end.month}${end.day}';
  reportName = '$prefix$targetSpecSec$startSec${endSec}_$suffix';
  return reportName;
}

bool canPullData(bool hasData, DateTime? lastRequst, int? reqInterval,
    DateTime? lastLoad, int? loadInteval) {
  if (!hasData) {
    return true;
  }

  bool pullData = true;
  if (lastRequst != null) {
    if (DateTime.now().difference(lastRequst).inSeconds < (reqInterval ?? 3)) {
      pullData = false;
    }
  }
  if (pullData) {
    if (hasData) {
      if (lastLoad != null) {
        if (DateTime.now().difference(lastLoad).inSeconds <
            (loadInteval ?? 60)) {
          pullData = false;
        }
      }
    }
  }
  return pullData;
}
