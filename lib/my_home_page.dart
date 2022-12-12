import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'chunk_item.dart';
import 'chunk_item_state.dart';
import 'scroll_state.dart';
import 'iterable_ext.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        _onScroll(scrollNotification, ref);
        return false;
      },
      child: ListView.builder(itemBuilder: (context, index) {
        return ChunkItem(
          index: index,
          cacheExtent: ref.watch(
            scrollStateProvider.select((value) => value.cacheExtent),
          ),
        );
      }),
    );
  }

  void _onScroll(ScrollNotification scrollNotification, WidgetRef ref) {
    final ScrollState prevScrollState = ref.read(scrollStateProvider);
    final chunkList = ref.read(chunkListItemStateListProvider);

    final ScrollDirection currentScrollDirection;
    if (scrollNotification is UserScrollNotification) {
      currentScrollDirection = scrollNotification.direction;
    } else {
      currentScrollDirection = prevScrollState.userScrollDirection;
    }

    final viewportTopOffset = scrollNotification.metrics.pixels;
    final viewportHeight = scrollNotification.metrics.viewportDimension;
    final viewportBottomOffset = (viewportTopOffset + viewportHeight);

    ChunkItemState? newNextForwardBottomTargetItem =
        prevScrollState.nextForwardBottomTargetItem;
    ChunkItemState? newNextReverseBottomTargetItem =
        prevScrollState.nextReverseBottomTargetItem;
    ChunkItemState? newNextForwardTopTargetItem =
        prevScrollState.nextForwardTopTargetItem;
    ChunkItemState? newNextReverseTopTargetItem =
        prevScrollState.nextReverseTopTargetItem;

    switch (currentScrollDirection) {
      case ScrollDirection.reverse:
        {
          final nextReverseBottomTargetItemTopOffset =
              prevScrollState.nextReverseBottomTargetItem?.topOffset;
          final prevViewportBottomOffset = prevScrollState.viewportBottomOffset;

          if (_shouldShowBottomChunk(
            nextReverseBottomTargetItemTopOffset,
            prevViewportBottomOffset,
            viewportBottomOffset,
          )) {
            _showBottomChunk(
              ref: ref,
              prevScrollState: prevScrollState,
              setNewNextForwardBottomTargetItem: (itemState) =>
                  newNextForwardBottomTargetItem = itemState,
              setNewNextReverseBottomTargetItem: (itemState) =>
                  newNextReverseBottomTargetItem = itemState,
            );
          }

          final nextReverseTopTargetItemBottomOffset =
              prevScrollState.nextReverseTopTargetItem?.bottomOffset;
          final prevViewportTopOffset = prevScrollState.viewportTopOffset;

          if (_shouldHideTopChunk(
            nextReverseTopTargetItemBottomOffset,
            prevViewportTopOffset,
            viewportTopOffset,
          )) {
            _hideTopChunk(
              ref: ref,
              prevScrollState: prevScrollState,
              chunkList: chunkList,
              setNewNextForwardTopTargetItem: (itemState) =>
                  newNextForwardTopTargetItem = itemState,
              setNewNextReverseTopTargetItem: (itemState) =>
                  newNextReverseTopTargetItem = itemState,
            );
          }
          break;
        }

      case ScrollDirection.forward:
        {
          final nextForwardTopTargetItemBottomOffset =
              prevScrollState.nextForwardTopTargetItem?.bottomOffset;
          final prevViewportTopOffset = prevScrollState.viewportTopOffset;

          if (_shouldShowTopChunk(
            nextForwardTopTargetItemBottomOffset,
            prevViewportTopOffset,
            viewportTopOffset,
          )) {
            _showTopChunk(
              ref: ref,
              prevScrollState: prevScrollState,
              setNewNextForwardTopTargetItem: (itemState) =>
                  newNextForwardTopTargetItem = itemState,
              setNewNextReverseTopTargetItem: (itemState) =>
                  newNextReverseTopTargetItem = itemState,
            );
          }

          final nextForwardBottomTargetItemTopOffset =
              prevScrollState.nextForwardBottomTargetItem?.topOffset;
          final prevViewportBottomOffset = prevScrollState.viewportBottomOffset;

          if (_shouldHideBottomChunk(
            nextForwardBottomTargetItemTopOffset,
            prevViewportBottomOffset,
            viewportBottomOffset,
          )) {
            _hideBottomChunk(
              ref: ref,
              prevScrollState: prevScrollState,
              setNewNextForwardBottomTargetItem: (itemState) =>
                  newNextForwardBottomTargetItem = itemState,
              setNewNextReverseBottomTargetItem: (itemState) =>
                  newNextReverseBottomTargetItem = itemState,
            );
          }
          break;
        }

      case ScrollDirection.idle:
        {
          break;
        }
    }

    final newScrollState = prevScrollState.copyWith(
      userScrollDirection: currentScrollDirection,
      viewportTopOffset: viewportTopOffset,
      viewportBottomOffset: viewportBottomOffset,
      nextForwardTopTargetItem: newNextForwardTopTargetItem,
      nextForwardBottomTargetItem: newNextForwardBottomTargetItem,
      nextReverseTopTargetItem: newNextReverseTopTargetItem,
      nextReverseBottomTargetItem: newNextReverseBottomTargetItem,
    );

    ref.read(scrollStateProvider.notifier).state = newScrollState;
  }

  bool _shouldShowBottomChunk(
    double? nextReverseBottomTargetItemTopOffset,
    double? prevViewportBottomOffset,
    double viewportBottomOffset,
  ) =>
      (nextReverseBottomTargetItemTopOffset != null &&
          prevViewportBottomOffset != null &&
          prevViewportBottomOffset < nextReverseBottomTargetItemTopOffset &&
          viewportBottomOffset >= nextReverseBottomTargetItemTopOffset);

  bool _shouldHideTopChunk(
    double? nextReverseTopTargetItemBottomOffset,
    double? prevViewportTopOffset,
    double viewportTopOffset,
  ) =>
      (nextReverseTopTargetItemBottomOffset != null &&
          prevViewportTopOffset != null &&
          prevViewportTopOffset < nextReverseTopTargetItemBottomOffset &&
          viewportTopOffset >= nextReverseTopTargetItemBottomOffset);

  bool _shouldShowTopChunk(
    double? nextForwardTopTargetItemBottomOffset,
    double? prevViewportTopOffset,
    double viewportTopOffset,
  ) =>
      (nextForwardTopTargetItemBottomOffset != null &&
          prevViewportTopOffset != null &&
          prevViewportTopOffset > nextForwardTopTargetItemBottomOffset &&
          viewportTopOffset <= nextForwardTopTargetItemBottomOffset);

  bool _shouldHideBottomChunk(
    double? nextForwardBottomTargetItemTopOffset,
    double? prevViewportBottomOffset,
    double viewportBottomOffset,
  ) =>
      (nextForwardBottomTargetItemTopOffset != null &&
          prevViewportBottomOffset != null &&
          prevViewportBottomOffset > nextForwardBottomTargetItemTopOffset &&
          viewportBottomOffset <= nextForwardBottomTargetItemTopOffset);

  void _showBottomChunk({
    required WidgetRef ref,
    required ScrollState prevScrollState,
    required void Function(ChunkItemState? itemState)
        setNewNextForwardBottomTargetItem,
    required void Function(ChunkItemState? itemState)
        setNewNextReverseBottomTargetItem,
  }) {
    final chunkItemStateList = ref.read(chunkListItemStateListProvider);

    final startIndex = prevScrollState.nextReverseBottomTargetItem?.index;

    final List<ChunkItemState> newList = [
      chunkItemStateList.elementAt(startIndex!).copyWith(isVisible: true)
    ];

    ///FIX: nullable
    for (int i = startIndex + 1; i < chunkItemStateList.length; i++) {
      final chunkItemState = chunkItemStateList.elementAt(i);

      if (chunkItemState.overlapsChunkScrollPos == true) {
        break;
      }
      newList.add(chunkItemState.copyWith(isVisible: true));
    }

    ref.read(chunkListItemStateListProvider.notifier).state = [
      ...chunkItemStateList
        ..replaceRange(
          startIndex,
          newList.last.index + 1,
          newList,
        )
    ];

    print(
        ' $startIndex .. ${newList.last.index}　have been changed from invisible to visible.');

    setNewNextForwardBottomTargetItem(
        prevScrollState.nextReverseBottomTargetItem);

    setNewNextReverseBottomTargetItem(
        chunkItemStateList.elementAtOrNull(newList.last.index + 1));
  }

  void _hideTopChunk({
    required WidgetRef ref,
    required ScrollState prevScrollState,
    required List<ChunkItemState> chunkList,
    required void Function(ChunkItemState? itemState)
        setNewNextForwardTopTargetItem,
    required void Function(ChunkItemState? itemState)
        setNewNextReverseTopTargetItem,
  }) {
    final chunkItemStateList = ref.read(chunkListItemStateListProvider);

    final endIndex = prevScrollState.nextReverseTopTargetItem?.index;

    final List<ChunkItemState> newList = [
      chunkItemStateList.elementAt(endIndex!).copyWith(isVisible: false)
    ];

    ///FIX: nullable
    for (int i = endIndex - 1; i >= 0; i--) {
      final chunkItemState = chunkItemStateList.elementAtOrNull(i);

      if (chunkItemState?.overlapsChunkScrollPos == true) {
        break;
      }

      if (chunkItemState != null) {
        newList.add(chunkItemState.copyWith(isVisible: false));
      }
    }

    final reversedNewList = newList.reversed;

    ref.read(chunkListItemStateListProvider.notifier).state = [
      ...chunkItemStateList
        ..replaceRange(
          reversedNewList.first.index,
          endIndex + 1,
          reversedNewList,
        )
    ];

    ChunkItemState? newNextReverseTopTargetItem;
    for (int i = endIndex + 1; i < chunkList.length; i++) {
      final chunkItemState = chunkItemStateList.elementAtOrNull(i);
      if (chunkItemState?.overlapsChunkScrollPos == true) {
        newNextReverseTopTargetItem = chunkItemState;
        break;
      }
    }

    print(
        ' ${reversedNewList.first.index} .. $endIndex　have been changed from visible to invisible.');

    setNewNextForwardTopTargetItem(prevScrollState.nextReverseTopTargetItem);
    setNewNextReverseTopTargetItem(newNextReverseTopTargetItem);
  }

  void _showTopChunk({
    required WidgetRef ref,
    required ScrollState prevScrollState,
    required void Function(ChunkItemState? itemState)
        setNewNextForwardTopTargetItem,
    required void Function(ChunkItemState? itemState)
        setNewNextReverseTopTargetItem,
  }) {
    final chunkItemStateList = ref.read(chunkListItemStateListProvider);

    final endIndex = prevScrollState.nextForwardTopTargetItem?.index;

    ///FIX: nullable
    final List<ChunkItemState> newList = [
      chunkItemStateList.elementAt(endIndex!).copyWith(isVisible: true)
    ];

    for (int i = endIndex - 1; i >= 0; i--) {
      final chunkItemState = chunkItemStateList.elementAt(i);

      if (chunkItemState.overlapsChunkScrollPos == true) {
        break;
      }
      newList.add(chunkItemState.copyWith(isVisible: true));
    }

    final reversedNewList = newList.reversed;

    ref.read(chunkListItemStateListProvider.notifier).state = [
      ...chunkItemStateList
        ..replaceRange(
          reversedNewList.first.index,
          endIndex + 1,
          reversedNewList,
        )
    ];

    print(
        ' ${reversedNewList.first.index} .. $endIndex　have been changed from invisible to visible.');

    setNewNextForwardTopTargetItem(
      chunkItemStateList.elementAtOrNull(reversedNewList.first.index - 1),
    );

    setNewNextReverseTopTargetItem(
      prevScrollState.nextForwardTopTargetItem,
    );
  }

  void _hideBottomChunk({
    required WidgetRef ref,
    required ScrollState prevScrollState,
    required void Function(ChunkItemState? itemState)
        setNewNextForwardBottomTargetItem,
    required void Function(ChunkItemState? itemState)
        setNewNextReverseBottomTargetItem,
  }) {
    final chunkItemStateList = ref.read(chunkListItemStateListProvider);

    final startIndex = prevScrollState.nextForwardBottomTargetItem?.index;

    final List<ChunkItemState> newList = [
      chunkItemStateList.elementAt(startIndex!).copyWith(isVisible: false)
    ];

    ///FIX: nullable
    for (int i = startIndex + 1; i < chunkItemStateList.length; i++) {
      final chunkItemState = chunkItemStateList.elementAt(i);

      if (chunkItemState.overlapsChunkScrollPos == true) {
        break;
      }
      newList.add(chunkItemState.copyWith(isVisible: false));
    }

    ref.read(chunkListItemStateListProvider.notifier).state = [
      ...chunkItemStateList
        ..replaceRange(
          startIndex,
          newList.last.index + 1,
          newList,
        )
    ];

    ChunkItemState? newNextForwardBottomTargetItem;
    for (int i = newList.first.index - 1; i >= 0; i--) {
      final chunkItemState = chunkItemStateList.elementAtOrNull(i);
      if (chunkItemState?.overlapsChunkScrollPos == true) {
        newNextForwardBottomTargetItem = chunkItemState;
        break;
      }
    }

    print(
        ' $startIndex .. ${newList.last.index}　have been changed from visible to invisible.');

    setNewNextForwardBottomTargetItem(
      newNextForwardBottomTargetItem,
    );
    setNewNextReverseBottomTargetItem(
      prevScrollState.nextForwardBottomTargetItem,
    );
  }
}
