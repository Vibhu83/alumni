import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;
  const ProfilePicture(
      {required this.imagePath,
      this.isEdit = false,
      required this.onClicked,
      Key? key})
      : super(key: key);

  String returnImagePath() {
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.blue.shade300;
    List<Widget> stackChildren = [];
    stackChildren.add(_buildImage());
    if (isEdit == true) {
      stackChildren.add(Positioned(
        child: buildEditIcon(color),
        bottom: 0,
        right: 4,
      ));
    }
    return Center(
      child: Stack(children: stackChildren),
    );
  }

  Widget _buildImage() {
    final image = NetworkImage(imagePath);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(
            onTap: onClicked,
          ),
        ),
      ),
    );
  }

  Widget buildCircle(
      {required Widget child, required double all, required Color color}) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }

  Widget buildEditIcon(Color color) {
    return buildCircle(
        child: buildCircle(
            child: const Icon(
              Icons.add_a_photo_rounded,
              color: Colors.white,
              size: 20,
            ),
            all: 8,
            color: color),
        all: 3,
        color: Colors.white);
  }
}
