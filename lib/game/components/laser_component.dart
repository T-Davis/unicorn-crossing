import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LaserComponent extends RectangleComponent
    with CollisionCallbacks, HasGameRef {
  LaserComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(10, 2), // Laser size
          paint: Paint()..color = Colors.red,
        );

  final double speed = 300; // Speed of the laser

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()); // Add a collision shape
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the laser to the right
    position.x += speed * dt;

    // Remove the laser if it moves off-screen
    if (position.x > gameRef.size.x) {
      removeFromParent();
    }
  }
}
