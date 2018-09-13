dbFun(double d) {
  print('${d + 1}');
}

void main() {
  print('${1.runtimeType}');
  print('${1.0.runtimeType}');
  print('${(1.0 + 1).runtimeType}');
  print('${(1 + 1.0).runtimeType}');
  print('${(1/3).runtimeType}');
  print('${(4/2).runtimeType}');
}