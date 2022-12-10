import 'package:chunk_list_view_sample/chunk_item.dart';
import 'package:chunk_list_view_sample/chunk_item_state.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scrollStateProvider = StateProvider<ScrollState>((ref) {
  return ScrollState(cacheExtent: 10000.0);
});

class ScrollState {
  final double cacheExtent;
  final double? viewportTopOffset;
  final double? viewportBottomOffset;
  final ScrollDirection userScrollDirection;
  final ChunkItemState? nextReverseTopTargetItem;
  final ChunkItemState? nextReverseBottomTargetItem;
  final ChunkItemState? nextForwardTopTargetItem;
  final ChunkItemState? nextForwardBottomTargetItem;

  ScrollState({
    required this.cacheExtent,
    this.viewportTopOffset,
    this.viewportBottomOffset,
    this.nextReverseBottomTargetItem,
    this.nextReverseTopTargetItem,
    this.nextForwardTopTargetItem,
    this.nextForwardBottomTargetItem,
    this.userScrollDirection = ScrollDirection.idle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScrollState &&
          runtimeType == other.runtimeType &&
          cacheExtent == other.cacheExtent &&
          viewportTopOffset == other.viewportTopOffset &&
          viewportBottomOffset == other.viewportBottomOffset &&
          userScrollDirection == other.userScrollDirection &&
          nextReverseTopTargetItem == other.nextReverseTopTargetItem &&
          nextReverseBottomTargetItem == other.nextReverseBottomTargetItem &&
          nextForwardTopTargetItem == other.nextForwardTopTargetItem &&
          nextForwardBottomTargetItem == other.nextForwardBottomTargetItem;

  @override
  int get hashCode =>
      cacheExtent.hashCode ^
      viewportTopOffset.hashCode ^
      viewportBottomOffset.hashCode ^
      userScrollDirection.hashCode ^
      nextReverseTopTargetItem.hashCode ^
      nextReverseBottomTargetItem.hashCode ^
      nextForwardTopTargetItem.hashCode ^
      nextForwardBottomTargetItem.hashCode;

  ScrollState copyWith({
    double? cacheExtent,
    double? viewportTopOffset,
    double? viewportBottomOffset,
    ScrollDirection? userScrollDirection,
    ///HACK: nullを代入できるようにするため、暫定でrequired対応
    required ChunkItemState? nextReverseTopTargetItem,
    required ChunkItemState? nextReverseBottomTargetItem,
    required ChunkItemState? nextForwardTopTargetItem,
    required ChunkItemState? nextForwardBottomTargetItem,
  }) {
    return ScrollState(
      cacheExtent: cacheExtent ?? this.cacheExtent,
      viewportTopOffset: viewportTopOffset ?? this.viewportTopOffset,
      viewportBottomOffset: viewportBottomOffset ?? this.viewportBottomOffset,
      userScrollDirection: userScrollDirection ?? this.userScrollDirection,
      ///OPTIMIZE nullを代入できるもっとスマートな方法を模索
      nextReverseTopTargetItem: nextReverseTopTargetItem,
      nextReverseBottomTargetItem: nextReverseBottomTargetItem,
      nextForwardTopTargetItem: nextForwardTopTargetItem,
      nextForwardBottomTargetItem: nextForwardBottomTargetItem,
    );
  }
}
