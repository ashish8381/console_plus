import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2PageState();
}

class _Test2PageState extends State<Test2> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Test3(),
              //   ),
              // );
              // !isActive?
              //   FloatingConsole.show(context)
              //     : FloatingConsole.hide();
            },
            child: Center(child: Text("Example of Console plus Plugin")),
          );
        },
      ),
    );
  }
}
