import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unicorn_crossing/game/components/asteroid_component.dart';

class BackgroundComponent extends Component with HasGameRef {
  BackgroundComponent({
    this.starCount = 100,
    this.speed = 50,
    this.asteroidSpawnRate = 2,
  });

  final int starCount;
  final double speed; // Speed of the background movement
  final double asteroidSpawnRate; // Asteroids spawned per second
  final Random _random = Random();

  double _timeSinceLastAsteroid = 0;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < starCount; i++) {
      final star = RectangleComponent(
        position: Vector2(
          _random.nextDouble() * gameRef.size.x,
          _random.nextDouble() * gameRef.size.y,
        ),
        size: Vector2.all(2), // Small pixelated star
        paint: Paint()..color = Colors.white54,
      );
      await add(star);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move all stars to the left
    for (final child in children) {
      if (child is RectangleComponent) {
        child.position.x -= speed * dt;

        // If a star moves out of the screen on the left,
        // reposition it to the right
        if (child.position.x + child.size.x < 0) {
          if (child is AsteroidComponent) {
            remove(child);
          } else {
            child.position.x = gameRef.size.x;
            child.position.y = _random.nextDouble() * gameRef.size.y;
          }
        }
      }
    }

    // Spawn asteroids at regular intervals
    _timeSinceLastAsteroid += dt;
    if (_timeSinceLastAsteroid >= 1 / asteroidSpawnRate) {
      _spawnAsteroid();
      _timeSinceLastAsteroid = 0;
    }
  }

  void _spawnAsteroid() {
    final asteroidSize = Vector2.all(
      12 + _random.nextDouble() * 20,
    );
    final asteroidPosition = Vector2(
      gameRef.size.x, // Spawn on the right edge
      _random.nextDouble() * gameRef.size.y, // Random vertical position
    );
    final asteroidSpeed = speed +
        20 +
        _random.nextDouble() * 30; // Random speed slightly faster than stars

    final asteroid = AsteroidComponent(
      position: asteroidPosition,
      size: asteroidSize,
      speed: asteroidSpeed,
    );

    add(asteroid);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Clear existing stars and regenerate them
    removeAll(children.whereType<RectangleComponent>());
    for (var i = 0; i < starCount; i++) {
      final star = RectangleComponent(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        size: Vector2.all(2), // Small pixelated star
        paint: Paint()..color = Colors.white54,
      );
      add(star);
    }
  }
}
