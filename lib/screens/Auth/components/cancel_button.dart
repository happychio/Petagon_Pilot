import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/constraints.dart';

class CancelButton extends StatelessWidget {
  const CancelButton(
      {Key? key,
      required this.isLogin,
      required this.animationDuration,
      required this.size,
      required this.animationController,
      required this.tapEvent})
      : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final AnimationController? animationController;
  final GestureTapCallback? tapEvent;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLogin ? 0.0 : 1.0,
      duration: animationDuration,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: size.width * 0.1,
          height: size.height * 0.1,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: kPrimaryColor,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: tapEvent,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
