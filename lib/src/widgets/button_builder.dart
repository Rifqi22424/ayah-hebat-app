import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class ButtonBuilder extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final bool? isLoadingWidget;

  const ButtonBuilder(
      {super.key, required this.onPressed, required this.child, this.isLoadingWidget});

  @override
  _ButtonBuilderState createState() => _ButtonBuilderState();
}

class _ButtonBuilderState extends State<ButtonBuilder> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        backgroundColor:
            WidgetStateProperty.all<Color>(AppColors.primaryColor),
        minimumSize:
            WidgetStateProperty.all<Size>(const Size(double.maxFinite, 50)),
      ),
      onPressed: () async {
        setState(() {
          isLoading = true;
        });

        try {
          await widget.onPressed();
        } catch (e) {
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      },
      child: isLoading || widget.isLoadingWidget == true
          ? const SizedBox(
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
