import 'package:flutter/material.dart';

class Notices extends StatefulWidget {
  final List<Map<String, dynamic>> notices;
  const Notices({required this.notices, Key? key}) : super(key: key);

  @override
  State<Notices> createState() => _NoticesState();
}

class _NoticesState extends State<Notices> {
  bool shouldReturnEmpty = false;

  @override
  Widget build(BuildContext context) {
    if (shouldReturnEmpty == true) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(90, 0, 162, 255)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: const Text(
              "Notices",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            height: 300,
            child: PageView.builder(
                itemCount: widget.notices.length,
                itemBuilder: ((context, index) {
                  return SingleChildScrollView(
                      child: Text(widget.notices[index]["noticeMessage"]));
                })),
          ),
          Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey))),
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                setState(() {
                  shouldReturnEmpty = true;
                });
              },
              child: const Text(
                "Dismiss",
                style: TextStyle(
                    color: Color.fromARGB(255, 141, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
