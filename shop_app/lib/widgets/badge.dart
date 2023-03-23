import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget? child;
  final String? value;
  final Color? color;

  Badge({@required this.child, @required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child!,
        Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: color == null ? Theme.of(context).accentColor : color),
              constraints: BoxConstraints(minHeight: 16, maxWidth: 16),
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: 10.0,
                ),
                textAlign: TextAlign.center,
              ),
            ))
      ],
    );
  }
}
