import 'package:flutter/material.dart';

import 'package:xt_ui/xt_ui.dart';

class xtInfoBox extends StatelessWidget {
  const xtInfoBox({
    Key? key,
    this.width,
    this.height,
    this.icon,
    this.iconTextPadding,
    this.text,
    this.textColor,
    this.boarderColor,
    this.borderRadius,
    // this.fontSize,
    // this.fontstyle,
    this.textStyle,
    this.padding,
    this.superText,
    this.superTextStyle,
    this.isSelectable,
  }) : super(key: key);

  final Icon? icon;
  final double? iconTextPadding;
  final String? text;
  final Color? boarderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  // final double? fontSize;
  // final FontStyle? fontstyle;
  final EdgeInsetsGeometry? padding;
  final String? superText;
  final TextStyle? superTextStyle;
  final bool? isSelectable;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: boarderColor ?? xtTransParent),
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
      ),
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: icon,
          ),
          SizedBox(width: iconTextPadding ?? 0),
          // Text(text ?? '',
          //     style: textStyle ??
          //         TextStyle(
          //             color: textColor ?? Colors.white,
          //             fontSize: 17,
          //             fontStyle: FontStyle.normal)),
          isSelectable ?? true
              ? getConent()
              : Text(
                  text ?? '',
                  style: textStyle ??
                      TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 17,
                          fontStyle: FontStyle.normal),
                )
        ],
      ),
    );
  }

  Widget getConent() {
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(text: text ?? '', style: textStyle),
          superText != null
              ? WidgetSpan(
                  child: Transform.translate(
                    offset: const Offset(2.0, -13.0),
                    child: Text(
                      superText!,
                      style: superTextStyle ?? const TextStyle(fontSize: 10),
                    ),
                  ),
                )
              : const TextSpan(),
        ],
      ),
      maxLines: 1,
    );
  }
}
