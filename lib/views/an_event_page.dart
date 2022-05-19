import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/full_screen_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatefulWidget {
  final String eventID;
  final Image? eventTitleImage;
  final String eventTitle;
  final int eventAttendeesNumber;
  final String eventHolder;
  final DateTime eventStartTime;
  final Duration eventDuration;
  final String? eventLink;
  const AnEventPage(
      {required this.eventID,
      this.eventTitleImage,
      required this.eventTitle,
      required this.eventHolder,
      required this.eventAttendeesNumber,
      required this.eventStartTime,
      required this.eventDuration,
      this.eventLink,
      Key? key})
      : super(key: key);

  @override
  State<AnEventPage> createState() => _AnEventPageState();
}

class _AnEventPageState extends State<AnEventPage> {
  late Map<String, bool> clickFlags;
  late int attendeeOffset;
  late bool isInitialBuild;
  late int attendees;

  @override
  void initState() {
    attendees = widget.eventAttendeesNumber;
    isInitialBuild = true;
    attendeeOffset = 0;
    clickFlags = {
      "attending": false,
      "bookmark": false,
    };
    super.initState();
  }

  Future<Map<String, dynamic>> getEventDetails() async {
    await getEventAttendanceStatus();
    dynamic variable = null;
    Map<String, dynamic> eventDetails = {
      "eventDescription": """Loren ipsum
      
      and son""",
      "peopleInEvent": [
        {
          "uid": variable,
          "name": "Guest1",
          "description": "Some position at some organisation",
          "email": "someEmail@example.com",
          "phone": "1234567890"
        },
        {"uid": "nhiTh5NYDaU64CsY5KDzgiU6DhD3"}
      ],
      "gallery": [
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn9.jfif?alt=media&token=41b9f759-9cd0-409d-8e4a-343ef698a897",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558"
      ]
    };
    List<Map<String, dynamic>> idHolder = [];
    for (int i = 0; i < eventDetails["peopleInEvent"].length; i++) {
      if (eventDetails["peopleInEvent"][i]["uid"] != null) {
        idHolder
            .add({"index": i, "uid": eventDetails["peopleInEvent"][i]["uid"]});
      }
    }
    List<Map<String, dynamic>> idDetails = await getPeopleDetailsByID(idHolder);
    for (Map<String, dynamic> map in idDetails) {
      int index = map.remove("index");
      eventDetails["peopleInEvent"][index] = map;
    }
    eventDetails["gallery"] = getImagesFromLinks(eventDetails["gallery"]);
    return eventDetails;
  }

  List<Image> getImagesFromLinks(List<String> links) {
    List<Image> galleryImages = [];
    for (String link in links) {
      galleryImages.add(Image.network(link));
    }
    return galleryImages;
  }

  Future<List<Map<String, dynamic>>> getPeopleDetailsByID(
      List<Map<String, dynamic>> idHolder) async {
    List<String> ids = idHolder.map((e) {
      String temp = e["uid"];
      return temp;
    }).toList();
    int count = -1;
    List<Map<String, dynamic>> details = await firestore!
        .collection("users")
        .where("uid", whereIn: ids)
        .get()
        .then((value) {
      return value.docs.map((e) {
        count++;
        Map<String, dynamic> value = e.data();
        String? phone;
        if (value["mobileContactNo"] == true) {
          phone = value["mobileContactNo"];
        }
        String? position;
        if (value["designation"] != null ||
            value["currentOrganisation"] != null) {
          position =
              value["designation"] + "at " + value["currentOrganisation"];
        }
        return {
          "uid": value["uid"],
          "index": idHolder[count]["index"],
          "name": value["name"],
          "description": position,
          "email": value["email"],
          "phone": phone
        };
      }).toList();
    });
    return details;
  }

  Future<bool?> getEventAttendanceStatus() async {
    if (isInitialBuild && userData["uid"] != null) {
      isInitialBuild = false;
      bool? isBeingAttended = await firestore!
          .collection("eventAttendanceStatus")
          .doc(userData["uid"])
          .get()
          .then((value) {
        return value.data()![widget.eventID];
      });
      isBeingAttended ??= false;
      print("user is attending event?" + isBeingAttended.toString());
      clickFlags["attending"] = isBeingAttended;
      return true;
    } else {
      return true;
    }
  }

  void changeAttendeeNumber() async {
    bool nextAttendingFlag = false;
    int nextAttendeeNum = 0;
    int changeInAttendeeNum = 0;
    if (clickFlags["attending"] == true) {
      nextAttendingFlag = false;
      changeInAttendeeNum = -1;
    } else {
      nextAttendingFlag = true;
      changeInAttendeeNum = 1;
    }
    nextAttendeeNum = attendees + changeInAttendeeNum;
    setState(() {
      attendees = nextAttendeeNum;
      clickFlags["attending"] = nextAttendingFlag;
      lastEventAttendeeChange = changeInAttendeeNum;
      lastEventBool = clickFlags["attending"];
    });
  }

  void deleteEvent() {
    firestore!.collection("events").doc(widget.eventID).delete();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 1,
      );
    }));
  }

  List<Widget> _setActionButtons() {
    List<Widget> appBarActions = [];
    if (userData["accessLevel"] == "admin") {
      IconButton shareButton = buildAppBarIcon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AskMessagePopUp(
                      editingFlag: false,
                      title: widget.eventTitle,
                      authorName: widget.eventHolder,
                      id: widget.eventID,
                      type: "event");
                });
          },
          icon: Icons.notification_add_rounded);
      appBarActions.add(shareButton);

      IconButton editButton = buildAppBarIcon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return CreateEvent(
                eventUpdationFlag: true,
                eventId: widget.eventID,
                eventDescription: null,
                eventDuration: widget.eventDuration.inHours,
                eventHolder: widget.eventHolder,
                eventLink: widget.eventLink,
                eventStartTime: widget.eventStartTime,
                eventTitle: widget.eventTitle,
              );
            }));
          },
          icon: Icons.edit);
      appBarActions.add(editButton);
      IconButton deleteButton = buildAppBarIcon(
          onPressed: () {
            deleteEvent();
          },
          icon: Icons.delete_rounded);
      appBarActions.add(deleteButton);
    }
    return appBarActions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEventDetails(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage(snapshot.data!);
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Scaffold _buildPage(Map<String, dynamic> details) {
    //setting various eventAction button's icon and color
    double appBarHeight = screenHeight * 0.045;
    Color bookMarkIconColor = Theme.of(context).appBarTheme.foregroundColor!;
    IconData bookMarkIcon = Icons.bookmark_add;
    Color attendingIconColor = Theme.of(context).appBarTheme.foregroundColor!;
    IconData attendingIcon = Icons.event_available_rounded;
    Color attendeeNumberColor = Theme.of(context).appBarTheme.foregroundColor!;
    attendeeOffset = 0;
    if (clickFlags["bookmark"] == true) {
      bookMarkIcon = Icons.bookmark_added;
      bookMarkIconColor = Colors.blue;
    }
    if (clickFlags["attending"] == true) {
      attendeeNumberColor = Colors.blue;
      attendingIconColor = Colors.blue;
      attendingIcon = Icons.event_busy_rounded;
    }
    //

    List<Widget> firstRowChildren = [
      Flexible(
        child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventTitle,
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.3, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: false,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                "By: " + widget.eventHolder,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  // color: Colors.grey.shade300
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Text(
                    attendees.toString(),
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: attendeeNumberColor),
                  ),
                  Text(
                    " Attendees",
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Theme.of(context)
                            .appBarTheme
                            .shadowColor!
                            .withOpacity(0.9)),
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.005,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 18,
                ),
                SizedBox(
                  width: screenWidth * 0.01,
                ),
                SizedBox(
                  width: (screenWidth * .38),
                  child: Text(
                      "On: " +
                          formatDateTime(widget.eventStartTime) +
                          " \nFor: " +
                          widget.eventDuration.inHours.toString() +
                          " hours",
                      style: GoogleFonts.lato(fontSize: 10)),
                ),
              ]),
            ],
          ),
        ),
      ),
    ];

    if (widget.eventTitleImage != null) {
      firstRowChildren.add(const Placeholder(
        fallbackHeight: 110,
        fallbackWidth: 125,
      ));
    }
    List<Widget> iconButtons = [
      IconButton(
          splashRadius: 1,
          onPressed: () {
            changeAttendeeNumber();
            changeAttendeeNumberInDB(widget.eventID);
          },
          icon: Icon(
            attendingIcon,
            color: attendingIconColor,
          )),
      IconButton(
          splashRadius: 1,
          onPressed: () {
            setState(() {
              if (clickFlags["bookmark"] == true) {
                clickFlags["bookmark"] = false;
              } else {
                clickFlags["bookmark"] = true;
              }
            });
          },
          icon: Icon(
            bookMarkIcon,
            color: bookMarkIconColor,
          )),
      IconButton(
          onPressed: () {
            if (widget.eventLink != null) {
              launchUrl(Uri.parse(widget.eventLink!));
            }
          },
          icon: const Icon(Icons.open_in_new))
    ];
    Widget eventOptions = Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .appBarTheme
                    .shadowColor!
                    .withOpacity(0.25),
                blurStyle: BlurStyle.solid,
                spreadRadius: 0.1,
                blurRadius: 0.5,
                offset: const Offset(0, -1),
              ),
            ],
            borderRadius: BorderRadius.circular(2)),
        height: screenHeight * .06,
        child: Card(
            color: Theme.of(context).appBarTheme.backgroundColor,
            shadowColor: Theme.of(context).appBarTheme.shadowColor,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: iconButtons,
            )));
    if (userData["uid"] == null) {
      eventOptions = const SizedBox(
        height: 0,
      );
    }
    List<Widget> appBarActions = _setActionButtons();
    List<Map<String, dynamic>> people = details["peopleInEvent"];
    return Scaffold(
      bottomNavigationBar: eventOptions,
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).canvasColor,
      appBar: buildAppBar(
          actions: appBarActions,
          appBarHeight: appBarHeight,
          leading: buildAppBarIcon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close)),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: firstRowChildren,
                ),
              ),
            ),
            Flexible(
              child: DefaultTabController(
                  length: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .appBarTheme
                                    .shadowColor!
                                    .withOpacity(0.15),
                                blurStyle: BlurStyle.solid,
                                spreadRadius: 0.1,
                                blurRadius: 0.5,
                                offset: const Offset(0, -1),
                              ),
                            ]),
                        child: Card(
                          shadowColor:
                              Theme.of(context).appBarTheme.shadowColor,
                          elevation: 0.2,
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          child: TabBar(
                              indicatorColor: Theme.of(context)
                                  .floatingActionButtonTheme
                                  .backgroundColor,
                              unselectedLabelColor: Theme.of(context)
                                  .appBarTheme
                                  .shadowColor!
                                  .withOpacity(0.6),
                              labelColor:
                                  Theme.of(context).appBarTheme.shadowColor,
                              tabs: const [
                                Tab(
                                  text: "Description",
                                ),
                                Tab(
                                  text: "People",
                                ),
                                Tab(
                                  text: "Gallery",
                                )
                              ]),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
                        color: Theme.of(context).canvasColor,
                        height: userData["uid"] != null
                            ? screenHeight * .65
                            : screenHeight * 0.71,
                        child: TabBarView(children: [
                          SingleChildScrollView(
                            child: Text(details["eventDescription"]),
                          ),
                          ListView.builder(
                              itemCount: people.length,
                              itemBuilder: ((context, index) {
                                String subTitle = "";
                                if (people[index]["description"] == null) {
                                  subTitle = "";
                                } else {
                                  subTitle = people[index]["description"];
                                }
                                return Container(
                                  margin: const EdgeInsets.only(
                                      left: 4, right: 4, top: 4, bottom: 8),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: ListTile(
                                    title: Text(people[index]["name"]),
                                    subtitle: Text(subTitle),
                                  ),
                                );
                              })),
                          GridView.builder(
                              itemCount: details["gallery"].length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5),
                              itemBuilder: (context, index) {
                                final Image image = details["gallery"][index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: ((context) {
                                      return FullScreenImageViewer(
                                          child: details["gallery"],
                                          dark: true);
                                    })));
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                    // color: const Color(postCardColor),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: image.image,
                                    ),
                                  )),
                                );
                              })
                        ]),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
