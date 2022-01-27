import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:slideparty/src/features/multiple_mode/controllers/multiple_mode_controller.dart';
import 'package:slideparty/src/features/playboard/playboard.dart';
import 'package:slideparty/src/features/playboard/widgets/playboard_view.dart';
import 'package:slideparty/src/widgets/widgets.dart';

class MultipleModePage extends ConsumerWidget {
  const MultipleModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerCount = ref.watch(
      playboardControllerProvider.select((value) {
        return (value as MultiplePlayboardState).playerCount;
      }),
    );

    switch (playerCount) {
      case 0:
        return const _NoPlayerPage();
      default:
        return _MultiplePlayerPage(playerCount: playerCount);
    }
  }
}

class _NoPlayerPage extends HookConsumerWidget {
  const _NoPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref
        .watch(playboardInfoControllerProvider.select((value) => value.color));
    final controller = ref.watch(playboardControllerProvider.notifier)
        as MultipleModeController;
    final playerChosen = useState([false, false, false]);
    final boardChosen = useState([false, false, false]);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 425),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Multiple Mode',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: color.primaryColor,
                      ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Number of players',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                const SizedBox(height: 8),
                SeparatedRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  separatorBuilder: () => const SizedBox(height: 10),
                  children: List.generate(
                    playerChosen.value.length,
                    (index) => SlidepartyButton(
                      color: color,
                      onPressed: () => playerChosen.value = List.generate(
                        playerChosen.value.length,
                        (i) => i == index,
                      ),
                      child: Text('${index + 2}'),
                      style: playerChosen.value[index]
                          ? SlidepartyButtonStyle.normal
                          : SlidepartyButtonStyle.invert,
                      customSize: Size((constraints.maxWidth - 20) / 3, 49),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Board size',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                const SizedBox(height: 8),
                SeparatedRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  separatorBuilder: () => const SizedBox(height: 10),
                  children: List.generate(
                    boardChosen.value.length,
                    (index) => SlidepartyButton(
                      color: color,
                      onPressed: () => boardChosen.value = List.generate(
                        playerChosen.value.length,
                        (i) => i == index,
                      ),
                      child: Text('${index + 3} x ${index + 3}'),
                      style: boardChosen.value[index]
                          ? SlidepartyButtonStyle.normal
                          : SlidepartyButtonStyle.invert,
                      customSize: Size((constraints.maxWidth - 20) / 3, 49),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SlidepartyButton(
                  color: color,
                  onPressed: () => controller.startGame(
                    playerChosen.value.indexOf(true) + 2,
                    boardChosen.value.indexOf(true) + 3,
                  ),
                  child: const Text('Start'),
                  customSize: Size(constraints.maxWidth, 49),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _MultiplePlayerPage extends ConsumerWidget {
  const _MultiplePlayerPage({
    Key? key,
    required this.playerCount,
  }) : super(key: key);

  final int playerCount;

  int get columnLength => playerCount ~/ 2 + (playerCount % 2 == 1 ? 1 : 0);

  Widget _multiplePlayerView(BuildContext context) {
    switch (playerCount) {
      case 2:
        return Row(
          children: [
            ...List.generate(
              playerCount,
              (index) => Expanded(
                child: _PlayerPlayboardView(playerIndex: index),
              ),
            ),
          ],
        );
      default:
        return Column(
          children: [
            ...List.generate(
                columnLength,
                (index) => Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                ...List.generate(
                                  playerCount % 2 == 1 &&
                                          index == columnLength - 1
                                      ? 1
                                      : 2,
                                  (colorIndex) => Expanded(
                                    child: _PlayerPlayboardView(
                                      playerIndex: index * 2 + colorIndex,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _multiplePlayerView(context),
    );
  }
}

class _PlayerPlayboardView extends ConsumerWidget {
  const _PlayerPlayboardView({Key? key, required this.playerIndex})
      : super(key: key);

  final int playerIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardSize = ref.watch(
      playboardControllerProvider.select(
        (value) => (value as MultiplePlayboardState).boardSize,
      ),
    );

    return Theme(
      data: Theme.of(context).colorScheme.brightness == Brightness.light
          ? ButtonColors.values[playerIndex].lightTheme
          : ButtonColors.values[playerIndex].darkTheme,
      child: LayoutBuilder(builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeInOutCubicEmphasized,
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PlayboardView(
                  boardSize: boardSize,
                  size: constraints.biggest.shortestSide - 32,
                  playerIndex: playerIndex,
                  onPressed: (_) {},
                  clipBehavior: Clip.none,
                ),
              ),
            ),
          ),
          builder: (context, value, child) => Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: constraints.biggest.height * value,
                  width: constraints.biggest.width * value,
                  child: child,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
