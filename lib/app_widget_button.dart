import 'package:flutter/material.dart';

class ExElevatedButton extends StatefulWidget {
  const ExElevatedButton({Key? key, required VoidCallback this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;
  //final Function()? onPressed;

  @override
  State<ExElevatedButton> createState() => _ExElevatedButtonState();
}

class _ExElevatedButtonState extends State<ExElevatedButton> {
  bool _isGreen = true;
  String _txt = 'set to red';

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: (_isGreen
            ? Colors.green
            : Colors.red),
        onPrimary: Colors.white,
        minimumSize: const Size(150, 40),
      ),
      //onPressed: _toggleColor(),
      onPressed: (){ _toggleColor();},
      child: Text(
        _txt,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  _toggleColor() {
    widget.onPressed?.call();
    setState(() {
      if (_isGreen) {
         _isGreen = false;
         _txt = 'set to green';
      } else {
        _isGreen = true;
        _txt = 'set to red';
      }
    });
  }
}
