import 'package:collection/collection.dart';

extension AmebaIterableExtension<T> on Iterable<T> {
  ///   collectionパッケージ1.17.0から入っているが、Flutter Testが1.16.0に依存しているため、
  ///   自前で導入
  T? elementAtOrNull(int index) {
    try {
      return skip(index).firstOrNull;
    } catch (e, s) {
      return null;
    }
  }
}
