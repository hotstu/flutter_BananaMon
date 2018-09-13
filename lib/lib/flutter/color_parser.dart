// Copyright (c) 2015, Viktor Dakalov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library color_parser;

import 'dart:ui';


enum Component { RED, GREEN, BLUE, ALPHA }

/// Return fewer
min(num a, num b) => a <= b ? a : b;

/// Return greater number
max(num a, num b) => a >= b ? a : b;

/// Correct hex component for input (f -> ff)
String hexin(String comp) => comp.length == 1 ? comp + comp : comp;

/// Correct hex component for output
String hexout(String comp) => comp.length == 1 ? "0$comp" : comp;

/// Convert dec component to hex
String tohex(num comp) => hexout(comp.toInt().toRadixString(16));

/// Convert hex component to dec
int fromhex(String comp) => int.parse(hexin(comp), radix: 16);

/// Default value of red component
num DEF_RED = 0;

/// Default value of green component
num DEF_GREEN = 0;

/// Default value of blue component
num DEF_BLUE = 0;

/// Default value of alpha component
num DEF_ALPHA = null;

/// Agreement on the map color format
List<List<String>> mapConventions = [
  ['r', 'g', 'b', 'a'],
  ['x', 'y', 'z', 'a']
];

/// Agreement on the list color format
List listConvention = [
  Component.RED,
  Component.GREEN,
  Component.BLUE,
  Component.ALPHA
];

_parseComponents(String input, String prefix, [String postfix = ")"]) {
  if (input.startsWith(prefix) && input.contains(postfix)) {
    return new List.from(input
        .substring(prefix.length, input.indexOf(postfix))
        .split(",")
        .map((c) => num.parse(c))
        .toList());
  }
  return [];
}

_parseRgb(String input) {
  var comps = _parseComponents(input, "rgb(");
  return [
    comps.length > 0 ? comps[0] : DEF_RED,
    comps.length > 1 ? comps[1] : DEF_GREEN,
    comps.length > 2 ? comps[2] : DEF_BLUE
  ];
}

_parseRgba(String input) {
  var comps = _parseComponents(input, "rgba(");
  return [
    comps.length > 0 ? comps[0] : DEF_RED,
    comps.length > 1 ? comps[1] : DEF_GREEN,
    comps.length > 2 ? comps[2] : DEF_BLUE,
    comps.length > 3 ? comps[3] : 1.0
  ];
}

_parseHex(String input) {
  if (input.length == 3) {
    return [input.substring(0, 1), input.substring(1, 2), input.substring(2, 3)]
        .map(fromhex)
        .toList();
  }

  if (input.length == 6) {
    return [input.substring(0, 2), input.substring(2, 4), input.substring(4, 6)]
        .map(fromhex)
        .toList();
  }

  return [];
}

_parseConst(String input) {
}

_parseList(List input) {
  int ri = listConvention.indexOf(Component.RED),
      gi = listConvention.indexOf(Component.GREEN),
      bi = listConvention.indexOf(Component.BLUE),
      ai = listConvention.indexOf(Component.ALPHA);

  return [
    ri >= 0 && input.length > ri ? input[ri] : null,
    gi >= 0 && input.length > gi ? input[gi] : null,
    bi >= 0 && input.length > bi ? input[bi] : null,
    ai >= 0 && input.length > ai ? input[ai] : null
  ];
}

_parseMap(Map input) {
  var conventions = new List.from(mapConventions).reversed.toList(),
      convention,
      result = new List();

  if (conventions.length == 0) {
    throw new Exception(
        "To create an object of Color from data a map type, you need specify one or more map conventions");
  }

  for (var index = 0; index < conventions.length; index++) {
    var convention = conventions[index], c = convention.length;

    if (convention.length != 4) {
      continue;
    }

    for (var j = 0; j < convention.length; j++) {
      if (input.containsKey(convention[j])) {
        c--;
      }
    }

    if (c >= result.length) {
      result.length = c + 1;
    }

    result.insert(c, convention);
  }

  if (result.length == 0) {
    throw new Exception(
        "The properties of the map does not match any of the conventions");
  }

  convention = result.firstWhere((c) => c is List);

  return [
    input[convention[0]],
    input[convention[1]],
    input[convention[2]],
    input[convention[3]]
  ];
}

_parseArgs(List args) {
  return [
    args.length > 0 && args[0] is num
        ? max(min(args[0].toInt(), 255), 0)
        : DEF_RED,
    args.length > 1 && args[1] is num
        ? max(min(args[1].toInt(), 255), 0)
        : DEF_GREEN,
    args.length > 2 && args[2] is num
        ? max(min(args[2].toInt(), 255), 0)
        : DEF_BLUE,
    args.length > 3 && args[3] is num
        ? max(min(args[3].toDouble(), 1.0), 0.0)
        : DEF_ALPHA
  ];
}

/// Factory for Color class
/// Default values for rgba components specify in [DEF_RED], [DEF_GREEN], [DEF_BLUE] and [DEF_ALPHA]
///
/// allow follow color format:
///
/// - rgba(255, 255, 255, 0.2)
/// - rgb(255, 255, 255)
/// - \#FfF
/// - \#FaFaFa
///
/// return [Color] object
Color ColorParser([dynamic red, num green, num blue, num alpha]) {
  var args;

  if (red is String) {
    if (red.contains(")")) {
      if (red.startsWith("rgba(")) {
        args = _parseRgba(red);
      } else if (red.startsWith("rgb(")) {
        args = _parseRgb(red);
      }
    } else if (red.startsWith("#")) {
      args = _parseHex(red.substring(1));
    } else {
      args = _parseConst(red);
    }
  } else if (red is List<num>) {
    args = _parseList(red);
  } else if (red is Map<dynamic, num>) {
    args = _parseMap(red);
  } else if (red is num || green is num || blue is num || alpha is num) {
    args = [red, green, blue, alpha];
  }

  if (args == null) {
    throw new Exception(
        "Invalid color format. Allowed formats: #FFF, #FFFFFF, rgba(255, 255, 255, 1.0) and rgb(255, 255, 255)");
  }

  args = _parseArgs(args);

  return Color.fromRGBO(args[0], args[1], args[2], args[3]??1.0);
}
