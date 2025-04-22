import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:unicorn_crossing/game/game.dart';
import 'package:unicorn_crossing/gen/assets.gen.dart';

class TappingBehavior extends Behavior<Unicorn>
    with TapCallbacks, HasGameRef<UnicornCrossing> {
  @override
  bool containsLocalPoint(Vector2 point) {
    return parent.containsLocalPoint(point);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (parent.isAnimationPlaying()) {
      return;
    }
    gameRef.counter++;
    parent.playAnimation();

    gameRef.effectPlayer.play(AssetSource(Assets.audio.effect));
  }
}
