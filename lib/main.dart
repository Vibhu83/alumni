import 'package:alumni/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const MainPage(),
  ));
}

class AnEventPage extends StatefulWidget {
  final int eventId;
  const AnEventPage({required this.eventId, Key? key}) : super(key: key);

  @override
  State<AnEventPage> createState() => _AnEventPageState();
}

class _AnEventPageState extends State<AnEventPage> {
  List getEventDetailsByID(int id) {
    return [];
  }

  late List eventDetails;
  @override
  void initState() {
    eventDetails = getEventDetailsByID(widget.eventId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
