import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<Image> child;
  final bool dark;
  const FullScreenImageViewer(
      {required this.child, required this.dark, Key? key})
      : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(
            shadowColor: Colors.black,
            background: Colors.black,
            leading: buildAppBarIcon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icons.close)),
        backgroundColor: widget.dark ? Colors.black : Colors.white,
        body: PageView.builder(
            itemCount: widget.child.length,
            itemBuilder: (context, index) {
              return _buildImage(widget.child[index]);
            }));
  }

  Widget _buildImage(Image image) {
    return Stack(
      children: [
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 333),
              curve: Curves.fastOutSlowIn,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: image,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
