import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unicorn_crossing/game/components/laser_component.dart';

class AsteroidComponent extends PositionComponent with CollisionCallbacks {
  AsteroidComponent({
    required Vector2 position,
    required Vector2 size,
    required double speed,
  })  : _speed = speed,
        super(
          position: position,
          size: size,
        );

  final double _speed;
  final Random _random = Random();
  final _hitbox = RectangleHitbox();
  late List<_Pixel> _pixels;
  bool _isExploding = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_hitbox); // Add a collision shape

    // Generate the pixelated blob shape
    _generatePixelatedShape();
  }

  void _generatePixelatedShape() {
    _pixels = [];
    const pixelSize = 4.0; // Fixed size for each pixel
    final gridSizeX =
        (size.x / pixelSize).floor(); // Number of pixels horizontally
    final gridSizeY =
        (size.y / pixelSize).floor(); // Number of pixels vertically

    // Center of the grid
    final centerX = gridSizeX / 2;
    final centerY = gridSizeY / 2;
    final maxDistance =
        min(gridSizeX, gridSizeY) / 2; // Maximum distance for a circular shape

    // Create a grid to track which cells are part of the blob
    for (var x = 0; x < gridSizeX; x++) {
      for (var y = 0; y < gridSizeY; y++) {
        // Calculate the distance from the center
        final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

        // Include the cell if it's within the circular radius
        if (distance <= maxDistance * (0.8 + _random.nextDouble() * 0.2)) {
          // Generate a random gray color
          final grayValue = 50 + _random.nextInt(100);
          final color = Color.fromARGB(255, grayValue, grayValue, grayValue);

          _pixels.add(
            _Pixel(
              rect: Rect.fromLTWH(
                x * pixelSize,
                y * pixelSize,
                pixelSize,
                pixelSize,
              ),
              color: color,
              velocity: Vector2(
                (_random.nextDouble() - 0.5) * 200, // Random x velocity
                (_random.nextDouble() - 0.5) * 200, // Random y velocity
              ),
              opacity: 1, // Initial opacity
            ),
          );
        }
      }
    }
  }

  void explode() {
    _isExploding = true;
    remove(_hitbox); // Remove the collision shape
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw each pixel in the blob
    for (final pixel in _pixels) {
      final paint = Paint()
        ..color = pixel.color.withValues(alpha: pixel.opacity); // Apply opacity
      canvas.drawRect(pixel.rect, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isExploding) {
      // Animate the pixels outward and fade them out
      for (final pixel in _pixels) {
        final rect = pixel.rect;
        final velocity = pixel.velocity;

        // Update the position of the pixel
        pixel
          ..rect = rect.translate(velocity.x * dt, velocity.y * dt)
          ..opacity -= dt; // Reduce opacity over time
        if (pixel.opacity < 0) {
          pixel.opacity = 0; // Clamp opacity to 0
        }
      }

      // Remove the asteroid after the explosion animation
      if (_pixels.every((pixel) => pixel.opacity <= 0)) {
        removeFromParent();
      }
    } else {
      // Move the asteroid to the left
      position.x -= _speed * dt;

      // Remove the asteroid if it moves out of the screen
      if (position.x + size.x < 0) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is LaserComponent) {
      // Trigger the explosion when hit by a laser
      explode();
      other.removeFromParent(); // Remove the laser
    }
  }
}

class _Pixel {
  _Pixel({
    required this.rect,
    required this.color,
    required this.velocity,
    required this.opacity,
  });
  Rect rect;
  final Color color;
  final Vector2 velocity;
  double opacity;
}
