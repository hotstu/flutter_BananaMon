
import 'dart:convert';

import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

Uint8List dataUrl2Byte(String  encode) {
  assert(encode !=  null);
  if(encode.startsWith("data:")) {
    encode = encode.split(",")[1];
  }
  assert(encode !=  null);
  return base64.decode(encode);
}

bool isVector2Zero(Vector2 v) {
  return v != null && v.x == 0.0 && v.y == 0.0;
}