import 'dart:math';
import 'package:flutter/material.dart';

/// A StatefulWidget that demonstrates a box animation including
/// movement across the screen, rotation, and color changes.

/// Only using Tween<T> + TweenSequence<T> + AnimationController + Animation<T>

class BoxAnimation extends StatefulWidget {
  const BoxAnimation({super.key});

  @override
  State<BoxAnimation> createState() => _BoxAnimationState();
}

class _BoxAnimationState extends State<BoxAnimation> with SingleTickerProviderStateMixin {
  /// Controls whether the animation is currently running.
  bool start = false;

  /// Manages the animation, including duration and progress.
  late AnimationController controller;

  /// Animates the box's position within the stack.
  late Animation<Alignment> alignmentAnimation;

  /// Animates the rotation of the box.
  late Animation<double> rotationAnimation;

  /// Animates the color of the box.
  late Animation<Color?> colorAnimation;

  /// Sequence of alignment changes for the box's movement.
  late TweenSequence<Alignment> tweenAlignment;

  /// Defines the range of rotation for the box.
  late Tween<double> tweenRotation;

  /// Sequence of color changes for the box.
  late TweenSequence<Color?> tweenColor;

  /// Represents one full rotation (2π radians).
  double rotation = 2 * pi;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 4-second duration.
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));

    // Define the sequence of alignments the box will animate through.
    tweenAlignment = TweenSequence<Alignment>(allAlignments());

    // Define the rotation from 0 to 4 full rotations.
    tweenRotation = Tween(begin: 0, end: 4 * rotation);

    // Define the sequence of color changes for the box.
    tweenColor = TweenSequence<Color?>(allColors());

    // Connect the alignment, rotation, and color animations to the controller.
    alignmentAnimation = controller.drive(tweenAlignment);
    rotationAnimation = tweenRotation.animate(controller);
    colorAnimation = tweenColor.animate(controller);
  }

  @override
  void dispose() {
    controller.dispose(); // Free up resources by disposing of the controller.
    super.dispose();
  }

  /// Returns a list of TweenSequenceItems for the alignment animation,
  /// defining the path the box takes.
  List<TweenSequenceItem<Alignment>> allAlignments() {
    return [
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(-0.8, -0.8),
          end: const Alignment(0.8, -0.8),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(0.8, -0.8),
          end: const Alignment(0.8, 0.8),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(0.8, 0.8),
          end: const Alignment(-0.8, 0.8),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(-0.8, 0.8),
          end: const Alignment(-0.8, -0.8),
        ),
        weight: 25,
      ),
    ];
  }

  /// Returns a list of TweenSequenceItems for the color animation,
  /// defining the color transitions of the box.
  List<TweenSequenceItem<Color?>> allColors() {
    return [
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: Colors.red.shade300,
          end: Colors.blueGrey.shade300,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: Colors.blueGrey.shade300,
          end: Colors.deepPurple.shade300,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: Colors.deepPurple.shade300,
          end: Colors.lime.shade300,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: Colors.lime.shade300,
          end: Colors.red.shade300,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ];
  }

  /// Toggles the animation state between start and stop.
  void move() {
    if (controller.isAnimating) {
      controller.stop();
    } else {
      if (controller.status == AnimationStatus.completed) {
        // Restart the animation if it has completed.
        controller.reset();
        controller.forward();
      } else {
        // Start the animation if it hasn't started or is paused.
        controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: move,
        child: const Icon(Icons.play_arrow_rounded),
      ),
      body: SizedBox.expand(
        child: Container(
          color: Colors.purple.shade50,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Stack(
                alignment: alignmentAnimation.value,
                children: [
                  Transform.rotate(
                    angle: rotationAnimation.value,
                    child: Container(
                      color: colorAnimation.value,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }


}
