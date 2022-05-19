import 'dart:io';

import 'package:alumni/globals.dart';
import 'package:alumni/views/an_event_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';

class CreateEvent extends StatefulWidget {
  final String? eventId;
  final String? eventTitle;
  final String? eventHolder;
  final DateTime? eventStartTime;
  final int? eventDuration;
  final String? eventLink;
  final String? eventTitleImage;
  final String? eventDescription;
  final List<String>? gallery;
  final List<Map<String, dynamic>>? peopleInEvent;
  final bool eventUpdationFlag;
  const CreateEvent(
      {this.eventId,
      this.eventTitle,
      this.eventTitleImage,
      this.eventHolder,
      this.eventStartTime,
      this.eventDuration,
      this.eventLink,
      this.eventDescription,
      this.gallery,
      this.peopleInEvent,
      required this.eventUpdationFlag,
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
  late List<Image> gallery;
  late List<Map<String, dynamic>> peopleInEvent;
  late DateTime? chosenStartTime;

  String? _titleError, _holderError, _durationError, _startTimeError;

  void resetError() {
    _titleError = null;
    _holderError = null;
    _durationError = null;
    _startTimeError = null;
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  Image? eventTitleImage;
  // late Color pageBackground;
  @override
  void initState() {
    gallery = [
      Image.network(
          "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fnpgc1.jpg?alt=media&token=7a60bbc8-63c2-4c23-9353-c7b5c1c976d9")
    ];
    if (widget.gallery != null) {
      for (String str in widget.gallery!) {
        gallery.add(Image.network(str));
      }
    }
    // pageBackground = const Color(eventPageBackground);
    if (widget.eventTitleImage != null) {
      eventTitleImage = Image.network(widget.eventTitleImage!);
    } else {
      eventTitleImage = null;
    }
    chosenStartTime = widget.eventStartTime;
    _titleController = TextEditingController(text: widget.eventTitle);
    _holderController = TextEditingController(text: widget.eventHolder);
    _durationController =
        initialiseController(widget.eventDuration.toString(), "");
    _linkController = initialiseController(widget.eventLink.toString(), "");
    _descriptionController =
        TextEditingController(text: widget.eventDescription);
    widget.peopleInEvent == null
        ? peopleInEvent = []
        : peopleInEvent = widget.peopleInEvent!;
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
      if (widget.eventUpdationFlag == false) {
        saveEvent();
      } else {
        updateEvent();
      }
    }
  }

  void updateEvent() async {
    String eventTitle = _titleController.text;
    String eventHolder = _holderController.text;
    int eventDuration = int.tryParse(_durationController.text)!;
    int eventAttendeesNumber = 0;
    String eventLink = _linkController.text;
    String eventDescription = _descriptionController.text;
    var eventStartTime = Timestamp.fromDate(chosenStartTime!);

    firestore!.collection('events').doc(widget.eventId).update({
      "eventAttendeesNumber": eventAttendeesNumber,
      "eventDuration": eventDuration,
      "eventHolder": eventHolder,
      "eventLink": eventLink,
      "eventStartTime": eventStartTime,
      "eventTitle": eventTitle,
      "eventTitleImage": null,
      "eventDescription": eventDescription
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 1,
      );
    }));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnEventPage(
          eventID: widget.eventId!,
          eventTitle: eventTitle,
          eventHolder: eventHolder,
          eventAttendeesNumber: eventAttendeesNumber,
          eventStartTime: eventStartTime.toDate(),
          eventDuration: Duration(hours: eventDuration));
    }));
  }

  void saveEvent() async {
    String eventTitle = _titleController.text;
    String eventHolder = _holderController.text;
    int eventDuration = int.tryParse(_durationController.text)!;
    int eventAttendeesNumber = 0;
    String eventLink = _linkController.text;
    String eventDescription = _descriptionController.text;
    var eventStartTime = Timestamp.fromDate(chosenStartTime!);

    String eventID =
        await firestore!.collection("events").add({}).then((value) async {
      String eventID = value.id;
      await firestore!.collection('events').doc(eventID).set({
        "eventID": eventID,
        "eventAttendeesNumber": eventAttendeesNumber,
        "eventDuration": eventDuration,
        "eventHolder": eventHolder,
        "eventLink": eventLink,
        "eventStartTime": eventStartTime,
        "eventTitle": eventTitle,
        "eventTitleImage": null,
        "eventDescription": eventDescription
      }, SetOptions(merge: true));
      return eventID;
    });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 1,
      );
    }));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnEventPage(
          eventID: eventID,
          eventTitle: eventTitle,
          eventHolder: eventHolder,
          eventAttendeesNumber: eventAttendeesNumber,
          eventStartTime: eventStartTime.toDate(),
          eventDuration: Duration(hours: eventDuration));
    }));
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //   return const MainPage(
    //     startingIndex: 1,
    //   );
    // }));
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String buttonText;
    if (widget.eventTitle != null) {
      title = "Edit the event";
      buttonText = "Edit";
    } else {
      title = "Create an event";
      buttonText = "Post";
    }
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      resizeToAvoidBottomInset: true,
      appBar: buildAppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        leading: buildAppBarIcon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icons.arrow_back),
        actions: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  // style: TextButton.styleFrom(primary: Colors.blue.shade100),
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
            _buildTitleImageInput(),
            _buildTitleInput(),
            _buildEventHolderInput(),
            _showDatePicker(),
            _buildDurationInput(),
            _buildEventLinkInput(),
            _buildDescriptionInput(),
            _buildPeopleInEventInput(),
            _buildGallery(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleImageInput() {
    dynamic child = TextButton(
        onPressed: () {
          ImagePicker()
              .pickImage(
                  source: ImageSource.gallery, maxHeight: 110, maxWidth: 125)
              .then((value) {
            if (value != null) {
              eventTitleImage = Image.file(File(value.path));
            } else {
              eventTitleImage = null;
            }
          });
        },
        child: const Text("Choose image"));
    if (eventTitleImage != null) {
      child = eventTitleImage;
    }
    return GroupBox(
      child: child,
      title: "Title Image(Optional)",
      // titleBackground: const Color(eventPageBackground)
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
    return GroupBox(
      errorText: _startTimeError,
      title: "Event Start Time *",
      // titleBackground: pageBackground,
      child: TextButton(
          onPressed: () {
            DatePicker.showDatePicker(context,
                theme: DatePickerTheme(
                    backgroundColor: Colors.grey.shade900,
                    itemStyle: const TextStyle(color: Colors.white),
                    cancelStyle: const TextStyle(color: Colors.deepOrange)),
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
          child: Text(buttonText)),
    );
  }

  Widget _buildDurationInput() {
    return SizedBox(
      width: screenWidth * .75,
      child: InputField(
        autoCorrect: false,
        controller: _durationController,
        labelText: "Duration (in hours)",
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

  Widget _buildPeopleInEventInput() {
    return GroupBox(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          SizedBox(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: peopleInEvent.length,
                itemBuilder: (context, index) {
                  String subTitle = "";
                  if (peopleInEvent[index]["description"] == null) {
                    subTitle = "";
                  } else {
                    subTitle = peopleInEvent[index]["description"];
                  }
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      trailing: IconButton(
                          iconSize: 20,
                          onPressed: () {
                            setState(() {
                              peopleInEvent.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.close)),
                      isThreeLine: true,
                      title: Text(peopleInEvent[index]["name"]),
                      subtitle: Text(subTitle),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AddPersonToEventPopUp(
                                uid: peopleInEvent[index]["uid"],
                                name: peopleInEvent[index]["name"],
                                description: peopleInEvent[index]
                                    ["description"],
                                number: peopleInEvent[index]["number"],
                                email: peopleInEvent[index]["email"],
                              );
                            }).then((value) {
                          if (value != null) {
                            setState(() {
                              peopleInEvent[index] = value;
                            });
                          }
                        });
                      },
                    ),
                  );
                }),
          ),
          IconButton(
              splashRadius: 16,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AddPersonToEventPopUp();
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      peopleInEvent.add(value);
                    });
                  }
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      title: "Add people to event",
      // titleBackground: pageBackground
    );
  }

  Widget _buildGallery() {
    return GroupBox(
        title: "Add images",
        // titleBackground: pageBackground,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            SizedBox(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: gallery.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: IconButton(
                                  splashRadius: 1,
                                  iconSize: 20,
                                  onPressed: () {
                                    setState(() {
                                      gallery.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.close)),
                            ),
                            SizedBox(
                              height: screenHeight * 0.025,
                            ),
                            Flexible(
                              child: IconButton(
                                  splashRadius: 1,
                                  iconSize: 20,
                                  onPressed: () {
                                    ImagePicker()
                                        .pickImage(source: ImageSource.gallery)
                                        .then((value) {
                                      if (value != null) {
                                        gallery[index] =
                                            Image.file(File(value.path));
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit)),
                            )
                          ],
                        ),
                        title: _buildImage(() {}, gallery[index]),
                        onTap: () {},
                      ),
                    );
                  }),
            ),
            IconButton(
                splashRadius: 16,
                onPressed: () {
                  ImagePicker().pickMultiImage().then((value) {
                    if (value != null) {
                      value.map((e) {
                        gallery.add(Image.file(File(e.path)));
                      });
                    }
                  });
                },
                icon: const Icon(Icons.add))
          ],
        ));
  }

  Widget _buildImage(void Function()? onClicked, Image image) {
    var imageProvider = image.image;
    return Material(
      color: Colors.transparent,
      child: Ink.image(
        image: imageProvider,
        fit: BoxFit.scaleDown,
        width: 128,
        height: 128,
        child: InkWell(
          onTap: onClicked,
        ),
      ),
    );
  }
}

class AddPersonToEventPopUp extends StatefulWidget {
  final int? personIndex;
  final String? uid;
  final String? name;
  final String? description;
  final String? number;
  final String? email;
  const AddPersonToEventPopUp(
      {this.personIndex,
      this.uid,
      this.name,
      this.description,
      this.number,
      this.email,
      Key? key})
      : super(key: key);

  @override
  State<AddPersonToEventPopUp> createState() => _AddPersonToEventPopUpState();
}

class _AddPersonToEventPopUpState extends State<AddPersonToEventPopUp> {
  late TextEditingController _name, _decription, _number, _email;
  String? _nameError, _emailError, _numberError;

  @override
  void initState() {
    _name = TextEditingController(text: widget.name);
    _decription = TextEditingController(text: widget.description);
    _number = TextEditingController(text: widget.number);
    _email = TextEditingController(text: widget.email);
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _decription.dispose();
    _number.dispose();
    _email.dispose();
    super.dispose();
  }

  bool validateFields() {
    bool isValid = true;
    String? name;
    String? number;
    String? email;

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (_email.text.isEmpty || !emailExp.hasMatch(_email.text)) {
      email = "Email is invalid";
      isValid = false;
    }
    if (_name.text.isEmpty) {
      name = "Please enter a name";
      isValid = false;
    }
    if (_number.text.isNotEmpty) {
      RegExp _numberExp = RegExp(r'^-?[0-9]+$');
      if (_numberExp.hasMatch(_number.text) != true) {
        number = "Invalid Number";
        isValid = false;
      }
    } else if (_number.text.length < 10) {
      number = "Phone number must be of 10 digits";
      isValid = false;
    }
    setState(() {
      _nameError = name;
      _emailError = email;
      _numberError = number;
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      height: screenHeight * 0.5,
      actions: [
        TextButton(
            onPressed: () {
              if (validateFields() == true) {
                Map<String, dynamic> returningMap = {
                  "uid": widget.uid,
                  "name": _name.text,
                  "description":
                      _decription.text == "" ? null : _decription.text,
                  "email": _email.text,
                  "phone": _number.text == "" ? null : _number.text
                };
                Navigator.pop(context, returningMap);
              }
            },
            child: const Text("Submit"))
      ],
      title: const Text("Add a person"),
      content: Column(
        children: [
          InputField(
            errorText: _nameError,
            controller: _name,
            labelText: "Name",
          ),
          InputField(
            controller: _decription,
            maxLines: 3,
            labelText: "Description",
          ),
          InputField(
            errorText: _numberError,
            controller: _number,
            labelText: "Phone Number(Optional)",
            maxLength: 10,
            keyboardType: TextInputType.phone,
          ),
          InputField(
            errorText: _emailError,
            controller: _email,
            labelText: "Email",
            keyboardType: TextInputType.emailAddress,
          )
        ],
      ),
    );
  }
}
