import 'package:chunk_list_view_sample/chunk_item.dart';
import 'package:chunk_list_view_sample/chunk_item_state.dart';
import 'package:chunk_list_view_sample/iterable_ext.dart';
import 'package:chunk_list_view_sample/scroll_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chunk List View Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
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
              final prevViewportBottomOffset =
                  prevScrollState.viewportBottomOffset;

              ///   ViewPortのbottomOffsetがあるItemのtopOffsetを飛び越えた時　下部のChunkを表示
              if (nextReverseBottomTargetItemTopOffset != null &&
                  prevViewportBottomOffset != null &&
                  prevViewportBottomOffset <
                      nextReverseBottomTargetItemTopOffset &&
                  viewportBottomOffset >=
                      nextReverseBottomTargetItemTopOffset) {
                final chunkItemStateList =
                    ref.read(chunkListItemStateListProvider);

                final startIndex =
                    prevScrollState.nextReverseBottomTargetItem?.index;

                final List<ChunkItemState> newList = [
                  chunkItemStateList
                      .elementAt(startIndex!)
                      .copyWith(isVisible: true)
                ];

                ///FIX: nullable
                for (int i = startIndex + 1;
                    i < chunkItemStateList.length;
                    i++) {
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

                newNextForwardBottomTargetItem =
                    prevScrollState.nextReverseBottomTargetItem;
                newNextReverseBottomTargetItem =
                    chunkItemStateList.elementAtOrNull(newList.last.index + 1);
              }

              final nextReverseTopTargetItemBottomOffset =
                  prevScrollState.nextReverseTopTargetItem?.bottomOffset;
              final prevViewportTopOffset = prevScrollState.viewportTopOffset;

              ///   ViewPortのtopOffsetがあるItemのbottomOffsetを飛び越えた時　上部のChunkを非表示
              if (nextReverseTopTargetItemBottomOffset != null &&
                  prevViewportTopOffset != null &&
                  prevViewportTopOffset <
                      nextReverseTopTargetItemBottomOffset &&
                  viewportTopOffset >= nextReverseTopTargetItemBottomOffset) {
                final chunkItemStateList =
                    ref.read(chunkListItemStateListProvider);

                final endIndex =
                    prevScrollState.nextReverseTopTargetItem?.index;

                final List<ChunkItemState> newList = [
                  chunkItemStateList
                      .elementAt(endIndex!)
                      .copyWith(isVisible: false)
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

                newNextForwardTopTargetItem =
                    prevScrollState.nextReverseTopTargetItem;
                newNextReverseTopTargetItem = newNextReverseTopTargetItem;
              }
              break;
            }

          case ScrollDirection.forward:
            {
              final nextForwardTopTargetItemBottomOffset =
                  prevScrollState.nextForwardTopTargetItem?.bottomOffset;
              final prevViewportTopOffset = prevScrollState.viewportTopOffset;

              ///   ViewPortのtopOffsetがあるItemのbottomOffsetを飛び越えた時　上部のChunkを表示
              if (nextForwardTopTargetItemBottomOffset != null &&
                  prevViewportTopOffset != null &&
                  prevViewportTopOffset >
                      nextForwardTopTargetItemBottomOffset &&
                  viewportTopOffset <= nextForwardTopTargetItemBottomOffset) {
                final chunkItemStateList =
                    ref.read(chunkListItemStateListProvider);

                final endIndex =
                    prevScrollState.nextForwardTopTargetItem?.index;

                ///FIX: nullable
                final List<ChunkItemState> newList = [
                  chunkItemStateList
                      .elementAt(endIndex!)
                      .copyWith(isVisible: true)
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

                newNextForwardTopTargetItem = chunkItemStateList
                    .elementAtOrNull(reversedNewList.first.index - 1);
                newNextReverseTopTargetItem =
                    prevScrollState.nextForwardTopTargetItem;
              }

              final nextForwardBottomTargetItemTopOffset =
                  prevScrollState.nextForwardBottomTargetItem?.topOffset;
              final prevViewportBottomOffset =
                  prevScrollState.viewportBottomOffset;

              ///   ViewPortのbottomOffsetがあるItemのtopOffsetを飛び越えた時 下部のChunkを非表示
              if (nextForwardBottomTargetItemTopOffset != null &&
                  prevViewportBottomOffset != null &&
                  prevViewportBottomOffset >
                      nextForwardBottomTargetItemTopOffset &&
                  viewportBottomOffset <=
                      nextForwardBottomTargetItemTopOffset) {
                final chunkItemStateList =
                    ref.read(chunkListItemStateListProvider);

                final startIndex =
                    prevScrollState.nextForwardBottomTargetItem?.index;

                final List<ChunkItemState> newList = [
                  chunkItemStateList
                      .elementAt(startIndex!)
                      .copyWith(isVisible: false)
                ];

                ///FIX: nullable
                for (int i = startIndex + 1;
                    i < chunkItemStateList.length;
                    i++) {
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

                newNextForwardBottomTargetItem = newNextForwardBottomTargetItem;
                newNextReverseBottomTargetItem =
                    prevScrollState.nextForwardBottomTargetItem;
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
}
