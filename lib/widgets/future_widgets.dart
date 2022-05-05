import 'package:flutter/material.dart';

List<Widget> buildFutureError(AsyncSnapshot snapshot) {
  return <Widget>[
    const Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 60,
    ),
    Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        '${snapshot.error}',
        style: const TextStyle(fontSize: 16),
      ),
    )
  ];
}

List<Widget> buildFutureLoading(AsyncSnapshot snapshot, {String? text}) {
  List<Widget> list = <Widget>[
    const SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(),
    ),
  ];
  if (text != null) {
    list.add(Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(text),
    ));
  }
  return list;
}

Widget buildFuture({required List<Widget> children}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    ),
  );
}
