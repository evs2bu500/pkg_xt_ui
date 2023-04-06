import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:xt_ui/xt_ui.dart';

class xtWait extends StatelessWidget {
  xtWait({Key? key, this.color, this.size}) : super(key: key);

  Color? color;
  double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: color ?? xtLightGreen1,
        size: size ?? 21,
      ),
    );
  }
}
