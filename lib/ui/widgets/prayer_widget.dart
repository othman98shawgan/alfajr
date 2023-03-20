import 'package:flutter/material.dart';
import 'card_widget.dart';

class PrayerWidget extends StatefulWidget {
  const PrayerWidget({Key? key, required this.label, required this.time, this.height = 0})
      : super(key: key);

  final String label;
  final String time;
  final double height;

  @override
  State<PrayerWidget> createState() => PrayerState();
}

class PrayerState extends State<PrayerWidget> {
  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 28,
    );

    return MyCard(
      height: widget.height,
      widget: ListTile(
        leading: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.label,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(""),
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.time,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}