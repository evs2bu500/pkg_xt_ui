import 'package:flutter/material.dart';
import 'package:xt_ui/xt_ui.dart';

enum btnKey { none, mainbutton }

class xtButton extends StatefulWidget {
  xtButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.xtKey,
    this.color = kcPrimaryColor,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 8,
    // this.errorText,
    // this.destPage = '/',
    this.formCoordinator,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  // String? errorText;
  btnKey? xtKey;
  xt_util_FormCorrdinator? formCoordinator;

  @override
  State<xtButton> createState() => _xtButtonState();
}

class _xtButtonState extends State<xtButton> {
  String? _errorText;
  bool _wait = false;

  @override
  void initState() {
    super.initState();
    if (widget.formCoordinator != null) {
      if (widget.xtKey != null) {
        widget.formCoordinator!
            .regFieldUpdateErrorText(widget.xtKey!, updateError);

        widget.formCoordinator!.regToggleWait(widget.xtKey!, toggleWait);
      }
    }
  }

  // final String? destPage;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius!),
                ),
              ),
              onPressed: widget.onPressed,
              child: Text(
                widget.text,
                style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
          if (_wait)
            Transform.translate(
              offset:
                  Offset(getSize(widget.key as GlobalKey)!.width * 0.17, -33),
              child: xtWait(
                color: Colors.white,
              ),
            ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(_errorText!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  void updateError(String? error) {
    setState(() {
      _errorText = error;
    });
  }

  void toggleWait(bool wait) {
    setState(() {
      _wait = wait;
    });
  }
}