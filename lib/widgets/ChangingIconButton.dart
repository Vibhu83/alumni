// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';

class ChangingIconButton extends StatefulWidget {
  final Color orginalColor;
  final Color onClickColor;
  final Function? onPressed;
  final IconData icon;
  final IconData? changedIcon;
  const ChangingIconButton(
      {required this.orginalColor,
      required this.onClickColor,
      required this.onPressed,
      required this.icon,
      this.changedIcon,
      Key? key})
      : super(key: key);

  @override
  State<ChangingIconButton> createState() => _ChangingIconButtonState();
}

class _ChangingIconButtonState extends State<ChangingIconButton> {
  bool clickedFlagIsTrue = false;
  late Color buttonColor;
  late IconData buttonIcon;
  void changeClickFlag() {
    setState(() {
      if (clickedFlagIsTrue) {
        clickedFlagIsTrue = false;
        buttonColor = widget.orginalColor;
        buttonIcon = widget.icon;
      } else {
        clickedFlagIsTrue = true;
        buttonColor = widget.onClickColor;
        if (widget.changedIcon != null) {
          buttonIcon = widget.changedIcon!;
        }
      }
    });
  }

  @override
  void initState() {
    buttonColor = widget.orginalColor;
    buttonIcon = widget.icon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          changeClickFlag();
          widget.onPressed;
        },
        splashRadius: 1,
        icon: Icon(
          buttonIcon,
          color: buttonColor,
        ));
  }
}
