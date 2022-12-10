import 'package:chunk_list_view_sample/chunk_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final chunkListItemStateListProvider =
    StateProvider.autoDispose<List<ChunkItemState>>(
  (ref) {
    return [];
  },
);

class ChunkItemState {
  final int index;
  final String key;
  final bool? isVisible;
  final bool? overlapsChunkScrollPos;
  final double? topOffset;
  final double? bottomOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChunkItemState &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          key == other.key &&
          isVisible == other.isVisible &&
          overlapsChunkScrollPos == other.overlapsChunkScrollPos &&
          topOffset == other.topOffset &&
          bottomOffset == other.bottomOffset &&
          mainExtent == other.mainExtent;

  @override
  int get hashCode =>
      index.hashCode ^
      key.hashCode ^
      isVisible.hashCode ^
      overlapsChunkScrollPos.hashCode ^
      topOffset.hashCode ^
      bottomOffset.hashCode ^
      mainExtent.hashCode;
  final double? mainExtent;

  ChunkItemState({
    required this.index,
    required this.key,
    this.isVisible,
    this.overlapsChunkScrollPos,
    this.topOffset,
    this.bottomOffset,
  }) : mainExtent = ((bottomOffset != null) && (topOffset != null))
            ? bottomOffset - topOffset
            : null;

  ChunkItemState copyWith({
    int? index,
    String? key,
    bool? isVisible,
    bool? overlapsChunkScrollPos,
    double? topOffset,
    double? bottomOffset,
    double? mainExtent,
  }) {
    return ChunkItemState(
      index: index ?? this.index,
      key: key ?? this.key,
      isVisible: isVisible ?? this.isVisible,
      overlapsChunkScrollPos:
          overlapsChunkScrollPos ?? this.overlapsChunkScrollPos,
      topOffset: topOffset ?? this.topOffset,
      bottomOffset: bottomOffset ?? this.bottomOffset,
    );
  }
}
