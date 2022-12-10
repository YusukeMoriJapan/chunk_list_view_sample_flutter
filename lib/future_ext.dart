import 'dart:async';

Future<T> postNextLoop<T>([FutureOr<T> Function()? computation]) =>
    Future.delayed(const Duration(milliseconds: 0), computation);

