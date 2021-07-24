import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0.0,
        title: Text(
          'HisFinder',
          style: TextStyle(
            fontFamily: 'avenir',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
          textScaleFactor: 1.4,
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: IconButton(
              icon: Image.asset("src/Category.png",
                  width: 65, height: 65, scale: 2.5),
              onPressed: () {
                // Category button Action
              }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
                icon: Image.asset("src/Bell.png",
                    width: 73, height: 76, scale: 3),
                onPressed: () {
                  // Bell Button Actoun
                }),
          ),
        ],
        backgroundColor: Color(0xff6990FF));
  }
}

class AlarmAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      title: Text(
        'Alarm',
        style: TextStyle(
          fontFamily: 'avenir',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
        ),
      ),
      leading: Image.asset(
        'src/back.png',
        width: 37,
        height: 69,
        scale: 3,
      ),
    );
  }
}
