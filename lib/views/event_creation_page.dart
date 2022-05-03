import 'package:alumni/globals.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/DefaultAppBar.dart';
import 'package:alumni/widgets/EventCard.dart';
import 'package:alumni/widgets/InputField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CreateEvent extends StatefulWidget {
  final String? id;
  final String? title;
  final String? eventHolder;
  final DateTime? startTime;
  final int? duration;
  final String? eventLink;
  final String? titleImage;
  final String? description;
  const CreateEvent(
      {this.id,
      this.title,
      this.titleImage,
      this.eventHolder,
      this.startTime,
      this.duration,
      this.eventLink,
      this.description,
      Key? key})
      : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  Function? createFireStoreDoc;
  late final TextEditingController _titleController;
  late final TextEditingController _holderController;
  late final TextEditingController _durationController;
  late final TextEditingController _linkController;
  late final TextEditingController _descriptionController;
  late DateTime? chosenStartTime;

  String? _titleError, _holderError, _durationError, _startTimeError;

  void resetError() {
    _titleError = null;
    _holderError = null;
    _durationError = null;
    _startTimeError = null;
  }

  @override
  void initState() {
    chosenStartTime = widget.startTime;
    _titleController = TextEditingController(text: widget.title);
    _holderController = TextEditingController(text: widget.eventHolder);
    _durationController = initialiseController(widget.duration.toString(), "");
    _linkController = initialiseController(widget.eventLink.toString(), "");
    _descriptionController = TextEditingController(text: widget.description);
    super.initState();
  }

  TextEditingController initialiseController(
      String initialiseWith, String defaultValue) {
    if (initialiseWith != "null") {
      return TextEditingController(text: initialiseWith);
    } else {
      return TextEditingController(text: defaultValue);
    }
  }

  bool validate() {
    resetError();
    String? title, holder, duration, startTime;
    bool isValid = true;
    if (_titleController.text.isEmpty) {
      title = "Cannot be empty";
      isValid = false;
    }
    if (_holderController.text.isEmpty) {
      holder = "Cannot be empty";
      isValid = false;
    }
    if (_durationController.text.isEmpty) {
      duration = "Cannot be empty";
      isValid = false;
    } else if (int.tryParse(_durationController.text) == null) {
      duration = "Duration must only have digits";
      isValid = false;
    }
    if (chosenStartTime == null) {
      startTime = "Start time must be chosen";
      isValid = false;
    }

    setState(() {
      _titleError = title;
      _holderError = holder;
      _durationError = duration;
      _startTimeError = startTime;
    });
    return isValid;
  }

  void submit() {
    if (validate()) {
      saveEvent();
    }
  }

  void saveEvent() {
    String title = _titleController.text;
    String holder = _holderController.text;
    int duration = int.tryParse(_durationController.text)!;
    int attendees = 0;
    String link = _linkController.text;
    String description = _descriptionController.text;
    var startTime = Timestamp.fromDate(chosenStartTime!);

    firestore!.collection('events').add({
      "attendees": attendees,
      "duration": duration,
      "holder": holder,
      "link": link,
      "startTime": startTime,
      "title": title,
      "titleImage": null
    }).then((value) {});
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 1,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    String text = "";
    if (_startTimeError != null) {
      text = _startTimeError!;
    }
    String title;
    String buttonText;
    if (widget.title != null) {
      title = "Edit the post";
      buttonText = "Edit";
    } else {
      title = "Create a post";
      buttonText = "Post";
    }
    double appBarHeight = screenHeight * 0.045;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        appBarHeight: appBarHeight,
        actions: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  style: TextButton.styleFrom(primary: Colors.blue.shade100),
                  onPressed: () {
                    submit();
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ListView(
          children: [
            _buildTitleInput(),
            _buildEventHolderInput(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Start Time:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _showDatePicker(),
                  ],
                ),
                Text(
                  text,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                )
              ],
            ),
            Row(
              children: [
                _buildDurationInput(),
                Text(
                  " in hours",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            _buildEventLinkInput(),
            _buildDescriptionInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return InputField(
      autoCorrect: true,
      maxLines: 2,
      controller: _titleController,
      labelText: "Title",
      errorText: _titleError,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildEventHolderInput() {
    return InputField(
      autoCorrect: true,
      maxLines: 2,
      controller: _holderController,
      labelText: "Event Holder",
      errorText: _holderError,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _showDatePicker() {
    String buttonText = "Choose event start time";
    if (chosenStartTime != null) {
      buttonText = formatDateTime(chosenStartTime!);
    }
    return TextButton(
        onPressed: () {
          DatePicker.showDatePicker(context,
              currentTime: chosenStartTime,
              minTime: DateTime.now(),
              maxTime: DateTime.now().add(const Duration(days: 365)),
              onConfirm: (date) {
            DateTime time = DateTime(2020);
            DatePicker.showTimePicker(context,
                currentTime: chosenStartTime,
                showSecondsColumn: false, onConfirm: (date) {
              time = date;
            }).then((value) {
              setState(() {
                chosenStartTime = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute);
              });
            });
          });
        },
        child: Text(buttonText));
  }

  Widget _buildDurationInput() {
    return SizedBox(
      width: screenWidth * .8,
      child: InputField(
        autoCorrect: false,
        controller: _durationController,
        labelText: "Duration",
        errorText: _durationError,
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildEventLinkInput() {
    return InputField(
      controller: _linkController,
      labelText: "Event Link (Optional)",
    );
  }

  Widget _buildDescriptionInput() {
    return InputField(
      autoCorrect: true,
      maxLines: 20,
      controller: _descriptionController,
      labelText: "Desciption(Optional)",
      keyboardType: TextInputType.multiline,
    );
  }
}