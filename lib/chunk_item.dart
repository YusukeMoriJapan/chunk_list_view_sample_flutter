import 'package:chunk_list_view_sample/chunk_item_state.dart';
import 'package:chunk_list_view_sample/future_ext.dart';
import 'package:chunk_list_view_sample/iterable_ext.dart';
import 'package:chunk_list_view_sample/scroll_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChunkItem extends HookConsumerWidget {
  const ChunkItem({
    required this.index,
    required this.cacheExtent,
    Key? key,
  }) : super(key: key);

  final int index;
  final double cacheExtent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ObjectRef<bool> isInitialized = useRef(false);
    final chunkListStateNotifier =
        ref.watch(chunkListItemStateListProvider.notifier);

    useAutomaticKeepAlive(wantKeepAlive: true);

    postNextLoop(
      () {
        final RenderObject? renderObject = context.findRenderObject();

        if (!isInitialized.value) {
          /// HACK: renderObjectがアタッチされていない場面でもう一度buildを回せていない。
          if (renderObject == null || !renderObject.attached) {
            return;
          }

          final RenderAbstractViewport? renderAbstractViewport =
              RenderAbstractViewport.of(renderObject);

          /// HACK: renderAbstractViewportが存在しない場合、もう位置buildを回す必要あり？
          if (renderAbstractViewport == null) {
            return;
          }

          final chunkListState = ref.read(chunkListItemStateListProvider);

          final topOffset = renderAbstractViewport
              .getOffsetToReveal(renderObject, 0.0)
              .offset;

          final bottomOffset = topOffset + renderObject.semanticBounds.height;

          final bool overlapsChunkScrollPos;

          if (topOffset % cacheExtent == 0) {
            overlapsChunkScrollPos = true;
          } else {
            final targetScrollPos =
                cacheExtent * ((topOffset / cacheExtent) + 1).toInt();
            if (topOffset < targetScrollPos && bottomOffset > targetScrollPos) {
              overlapsChunkScrollPos = true;
            } else {
              overlapsChunkScrollPos = false;
            }
          }

          if (chunkListState.elementAtOrNull(index) == null) {
            chunkListState.add(
              ChunkItemState(
                /// keyは仮置
                key: index.toString(),
                index: index,
                topOffset: topOffset,
                bottomOffset: bottomOffset,
                overlapsChunkScrollPos: overlapsChunkScrollPos,
              ),
            );
          } else {
            chunkListState[index] = chunkListState[index].copyWith(
              /// keyは仮置
              key: index.toString(),
              index: index,
              topOffset: topOffset,
              bottomOffset: bottomOffset,
              overlapsChunkScrollPos: overlapsChunkScrollPos,
            );
          }

          chunkListStateNotifier.state =
              chunkListState.sorted((a, b) => a.index.compareTo(b.index));

          if (overlapsChunkScrollPos) {
            final scrollState = ref.read(scrollStateProvider);
            final nextReverseTopTargetItem =
                (scrollState.nextReverseTopTargetItem == null)
                    ? chunkListState[index]
                    : scrollState.nextReverseTopTargetItem;

            ref.read(scrollStateProvider.notifier).state = scrollState.copyWith(
              nextReverseBottomTargetItem: chunkListState[index],
              nextForwardBottomTargetItem: chunkListState[index],
              nextReverseTopTargetItem: nextReverseTopTargetItem,
              nextForwardTopTargetItem: scrollState.nextForwardTopTargetItem,
            );
          }

          isInitialized.value = true;
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Visibility(
        visible: ref.watch(
          chunkListItemStateListProvider.select(
            (value) => value.elementAtOrNull(index)?.isVisible ?? true,
          ),
        ),
        replacement: const SizedBox(
          height: 100,
          width: double.infinity,
        ),

        ///Fake Image Widget　本来はここにImageWidgetが入る
        child: Container(
          width: double.infinity,
          height: 100,
          color: Colors.green,
        ),
      ),
    );
  }
}
