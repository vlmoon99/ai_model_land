import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({required this.onPressed, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all(Color.fromARGB(255, 95, 138, 250)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 19),
      ),
    );
  }
}
