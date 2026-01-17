import 'package:flutter/material.dart';

class FlyToCartAnimation extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;
  final VoidCallback onFinish;

  const FlyToCartAnimation({
    super.key,
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.onFinish,
  });

  @override
  State<FlyToCartAnimation> createState() => _FlyToCartAnimationState();
}

class _FlyToCartAnimationState extends State<FlyToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> position;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    position = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    scale = Tween<double>(
      begin: 1,
      end: 0.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward().then((_) => widget.onFinish());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Positioned(
          left: position.value.dx,
          top: position.value.dy,
          child: Transform.scale(
            scale: scale.value,
            child: Image.network(
              widget.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
}
