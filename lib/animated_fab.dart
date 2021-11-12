import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class FABTransition extends AnimatedWidget {
  FABTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key, listenable: animation);

  final Animation<double> animation;
  final Widget child;

  static final opacityTween = Tween<double>(begin: 1, end: 0);
  static final sizeTween = Tween<double>(begin: 1, end: 0);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: opacityTween.evaluate(animation).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: sizeTween.evaluate(animation),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class AnimatedFAB extends StatefulWidget {
  final Widget child;
  final Function() onPressed;
  final Color backgroundColor;

  const AnimatedFAB({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _AnimatedFABState createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late Widget child;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInBack);
    child = widget.child;
    backgroundColor = widget.backgroundColor;
  }

  @override
  void didUpdateWidget(AnimatedFAB oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child != child || widget.backgroundColor != backgroundColor) {
      controller.reset();
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            child = widget.child;
            backgroundColor = widget.backgroundColor;
          });
          controller.reverse();
        }
      });
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FABTransition(
      animation: animation,
      child: FloatingActionButton(
        child: child,
        onPressed: widget.onPressed,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
