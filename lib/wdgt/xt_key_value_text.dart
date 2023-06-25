import 'package:flutter/material.dart';

class xtKeyValueText extends StatelessWidget {
  //boilerplate
  const xtKeyValueText({
    Key? key,
    required this.keyText,
    required this.valueText,
    this.valueStyle,
    this.keyStyle,
    this.keyWidth,
    this.valueWidth,
    this.valueLoadingAnim,
    this.spaceInBetween = 5,
    this.selectable,
  }) : super(key: key);

  final String keyText;
  final String valueText;
  final TextStyle? valueStyle;
  final TextStyle? keyStyle;
  final double? keyWidth;
  final double? valueWidth;
  final double spaceInBetween;
  final Widget? valueLoadingAnim;
  final bool? selectable;

  @override
  Widget build(BuildContext context) {
    return selectable == null || !selectable!
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: keyWidth,
                child: Text(
                  keyText,
                  style: keyStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ),
              SizedBox(
                width: spaceInBetween,
              ),
              valueLoadingAnim == null
                  ? SizedBox(
                      width: valueWidth,
                      child: Text(
                        valueText,
                        style: valueStyle ??
                            TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    )
                  : valueLoadingAnim!,
            ],
          )
        : SelectableText.rich(
            getContent(context),
            // textAlign: TextAlign.left,
            // textDirection: TextDirection.ltr,
            // showCursor: false,
            // selectionControls: null,
            // autofocus: false,
            // strutStyle: null,
            // textWidthBasis: null,
            // textHeightBehavior: null,
            maxLines: 1,
            // semanticsLabel: null,
          );
  }

  TextSpan getContent(BuildContext context) {
    return TextSpan(
      text: keyText,
      style: keyStyle ??
          TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
      children: [
        valueLoadingAnim == null
            ? TextSpan(
                text: valueText,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              )
            : WidgetSpan(
                child: valueLoadingAnim!,
                alignment: PlaceholderAlignment.middle,
              ),
      ],
    );
  }
}
