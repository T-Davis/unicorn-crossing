import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:unicorn_crossing/game/game.dart';
import 'package:unicorn_crossing/l10n/l10n.dart';

class UnicornCrossing extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  UnicornCrossing({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  @override
  Color backgroundColor() => const Color(0xFF000000); // Black background

  @override
  Future<void> onLoad() async {
    removeAll(children); // Remove all existing children

    final world = World(
      children: [
        BackgroundComponent(starCount: 200), // Add the background with stars
        Unicorn(position: Vector2(50, size.y / 2)),
      ],
    );

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }
}
