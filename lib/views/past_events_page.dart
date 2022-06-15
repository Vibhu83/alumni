import 'package:alumni/views/events_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:flutter/material.dart';

class PastEventsPage extends StatefulWidget {
  const PastEventsPage({Key? key}) : super(key: key);

  @override
  State<PastEventsPage> createState() => _PastEventsPageState();
}

class _PastEventsPageState extends State<PastEventsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(
            title: const Text(
              "Past events",
              textAlign: TextAlign.left,
            ),
            leading: buildAppBarIcon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icons.close)),
        body: const EventsPage(
          showOnlyPastEvents: true,
        ));
  }
}
