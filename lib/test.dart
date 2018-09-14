import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

dbFun(double d) {
  print('${d + 1}');
}

testType() {
  print('${1.runtimeType}');
  print('${1.0.runtimeType}');
  print('${(1.0 + 1).runtimeType}');
  print('${(1 + 1.0).runtimeType}');
  print('${(1/3).runtimeType}');
  print('${(4/2).runtimeType}');
}

testMatrix() {
  final w = 192.0;
  final padding = 32.0;
  final height = 600;
  var lt = Vector3(0.0, 0.0, 0.0);
  var matrix4 = Matrix4.identity()
    ..rotateZ(math.pi * 0.25)
    ..translate(-100.0, -100.0);
  print(matrix4.transform3(lt));

}

void main() {
  testMatrix();
}