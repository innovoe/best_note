import 'package:flutter/material.dart';

class Gapper extends StatefulWidget {
  const Gapper({Key? key}) : super(key: key);

  @override
  GapperState createState() => GapperState();
}

class GapperState extends State<Gapper> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    controller.repeat(reverse: true); //looping in a reverse manner
    FocusManager.instance.primaryFocus?.unfocus(); // remove focus from other text fields
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
      child: FadeTransition(
        opacity: controller,
        child: Container(
            color: Colors.black26,
            height: 150,
            width: 2
        ),
      ),
    );
  }

  void blink(){
    controller.repeat(reverse: true); //looping in a reverse manner
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void stop(){
    controller.reset();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
