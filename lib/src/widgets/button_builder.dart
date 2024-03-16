import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class ButtonBuilder extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;

  const ButtonBuilder(
      {super.key, required this.onPressed, required this.child});

  @override
  _ButtonBuilderState createState() => _ButtonBuilderState();
}

class _ButtonBuilderState extends State<ButtonBuilder> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        backgroundColor:
            MaterialStateProperty.all<Color>(AppColors.primaryColor),
        minimumSize:
            MaterialStateProperty.all<Size>(const Size(double.maxFinite, 50)),
      ),
      onPressed: () async {
        setState(() {
          isLoading = true;
        });

        try {
          await widget.onPressed();
        } catch (e) {
          // Handle error as needed
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      },
      child: isLoading
          ? SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.child,
    );
  }
}
