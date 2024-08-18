import 'package:flutter/material.dart';

class BoxAnimationRecreation1 extends StatefulWidget {
  const BoxAnimationRecreation1({super.key});

  @override
  State<BoxAnimationRecreation1> createState() => _BoxAnimationRecreation1State();
}

class _BoxAnimationRecreation1State extends State<BoxAnimationRecreation1> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Tween<double> scaleTween;
  late Animation<RelativeRect> relativeRectAnimation;

  late double screenHeight;
  late double screenWidth;
  final Size boxSize = const Size(100,100);
  final EdgeInsets screenPadding = const EdgeInsets.fromLTRB(20, 100, 20, 100);


  @override
  void initState() {


    controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    scaleTween = Tween<double>(begin: 1, end: 2);
    scaleAnimation = scaleTween.animate(CurvedAnimation(parent: controller, curve: Curves.linear));



    super.initState();
    controller.addStatusListener((status) {

      // if(status == AnimationStatus.completed) controller.reverse();
    });
  }

  @override
  void didChangeDependencies() {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    relativeRectAnimation = TweenSequence<RelativeRect>(allRelativeRect(screenHeight, screenWidth)).animate(controller);
    super.didChangeDependencies();
  }





  List<TweenSequenceItem<RelativeRect>> allRelativeRect(double screenHeight, double screenWidth) {

    return [
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB(screenPadding.left, screenPadding.top, (screenWidth-(screenPadding.left+boxSize.width)), (screenHeight-(screenPadding.top+boxSize.height))),
          end: RelativeRect.fromLTRB((screenWidth - (screenPadding.right + boxSize.width)), screenPadding.top, screenPadding.right, (screenHeight-(screenPadding.top+boxSize.height))),
        ),
        weight: 25,
      ),
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB((screenWidth - (screenPadding.right + boxSize.width)), screenPadding.top, screenPadding.right, (screenHeight-(screenPadding.top+boxSize.height))),
          end: RelativeRect.fromLTRB((screenWidth - (screenPadding.right + boxSize.width)), (screenHeight-(screenPadding.bottom+boxSize.height)), screenPadding.right, screenPadding.bottom),
        ),
        weight: 25,
      ),
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB((screenWidth - (screenPadding.right + boxSize.width)), (screenHeight-(screenPadding.bottom+boxSize.height)), screenPadding.right, screenPadding.bottom),
          end: RelativeRect.fromLTRB(screenPadding.left, (screenHeight-(screenPadding.bottom+boxSize.height)), (screenWidth - (screenPadding.left + boxSize.width)), screenPadding.bottom),
        ),
        weight: 25,
      ),
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB(screenPadding.left, (screenHeight-(screenPadding.bottom+boxSize.height)), (screenWidth - (screenPadding.left + boxSize.width)), screenPadding.bottom),
          end: RelativeRect.fromLTRB(screenPadding.left, screenPadding.top, (screenWidth-(screenPadding.left+boxSize.width)), (screenHeight-(screenPadding.top+boxSize.height))),
        ),
        weight: 25,
      ),




    ];
  }

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
      extendBodyBehindAppBar: true,
      // appBar: AppBar(title: Text('Appbar'), backgroundColor: Colors.transparent,),
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // //background Image
            // Positioned.fill(child: Container(
            //   decoration: const BoxDecoration(
            //     image: DecorationImage(image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
            //   ),
            // ),),


            PositionedTransition(
              rect: relativeRectAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.teal,
                ),

                width: boxSize.width,
                height: boxSize.height,

              ),
            ),
            // IconButton
            Positioned(
              bottom: 50,
              right: 50,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                onPressed: move,
                icon: const Icon(
                  Icons.add,
                  size: 50,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
