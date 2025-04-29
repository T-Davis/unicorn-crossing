import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unicorn_crossing/game/components/asteroid_component.dart';
import 'package:unicorn_crossing/game/components/game_over_component.dart';
import 'package:unicorn_crossing/game/components/laser_component.dart';
import 'package:unicorn_crossing/gen/assets.gen.dart';

class Unicorn extends PositionedEntity
    with HasGameRef, KeyboardHandler, CollisionCallbacks {
  Unicorn({
    required super.position,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(50),
        );

  @visibleForTesting
  Unicorn.test({
    required super.position,
    super.behaviors,
  }) : super(size: Vector2.all(50));

  late SpriteAnimationComponent _animationComponent;

  final Set<LogicalKeyboardKey> _keysPressed = {};

  @visibleForTesting
  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: size)); // Add a collision shape

    final animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache(Assets.images.unicornAnimation.path),
      SpriteAnimationData.sequenced(
        amount: 16,
        stepTime: 0.1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );

    await add(
      _animationComponent = SpriteAnimationComponent(
        animation: animation,
        size: size * 2,
        position: -size / 2,
      ),
    );

    resetAnimation();
  }

  void resetAnimation() {
    animationTicker
      ..currentIndex = animationTicker.spriteAnimation.frames.length - 1
      ..update(0.1)
      ..currentIndex = 0;
  }

  /// Plays the animation.
  void playAnimation() => animationTicker.reset();

  /// Returns whether the animation is playing or not.
  bool isAnimationPlaying() => !animationTicker.done();

  /// Moves the unicorn up by a specified amount.
  void moveUp(double amount) {
    position.y -= amount;
    position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);
  }

  /// Moves the unicorn down by a specified amount.
  void moveDown(double amount) {
    position.y += amount;
    position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);

      // Shoot a laser when the spacebar is pressed
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _shootLaser();
      }
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
    return true; // Consume the event
  }

  void _shootLaser() {
    final laser = LaserComponent(
      position: Vector2(
        position.x + size.x / 2,
        position.y,
      ), // Start at the unicorn's position
    );
    gameRef.add(laser);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move continuously while keys are pressed
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      moveUp(200 * dt); // Move up at a speed of 200 units per second
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      moveDown(200 * dt); // Move down at a speed of 100 units per second
    }
  }

  /// Handle collision with asteroids
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is AsteroidComponent) {
      // Handle the unicorn's death
      removeFromParent(); // Remove the unicorn from the game

      gameRef.pauseEngine();
      // Add the Game Over screen
      gameRef.overlays.addEntry(
        'gameOver',
        (context, game) => GameOverWidget(
          onRestart: () {
            gameRef.overlays.remove('gameOver');
            gameRef.onLoad();
            gameRef.resumeEngine();
          },
        ),
      );
      gameRef.overlays.add('gameOver');
    }
  }
}
