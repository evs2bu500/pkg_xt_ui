import 'package:flutter/material.dart';

import 'package:xt_ui/xt_ui.dart';

class xtInfoBox extends StatelessWidget {
  const xtInfoBox({
    Key? key,
    this.width,
    this.height,
    this.icon,
    this.text,
    this.textColor,
    this.boarderColor,
    this.borderRadius,
  }) : super(key: key);

  final Icon? icon;
  final String? text;
  final Color? boarderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: boarderColor ?? Colors.white),
        // borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(13.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: icon,
          ),
          SizedBox(
            width: width ?? 0.7 * MediaQuery.of(context).size.width,
            child: Text(text ?? '',
                style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 17,
                    fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}
