import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/full_screen_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatefulWidget {
  final String eventID;
  final Image? eventTitleImage;
  final String? eventTitleImagePath;
  final String eventTitle;
  final int eventAttendeesNumber;
  final String eventHolder;
  final DateTime eventStartTime;
  final Duration eventDuration;
  final String? eventLink;
  const AnEventPage(
      {required this.eventID,
      this.eventTitleImage,
      this.eventTitleImagePath,
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
  late List<Map<String, dynamic>> people;
  late String description;
  late List<Image> gallery;
  late List<String> galleryUrls;
  late int _selectedTab;

  @override
  void initState() {
    _selectedTab = 0;
    galleryUrls = [];
    people = [];
    gallery = [];
    description = "";
    attendees = widget.eventAttendeesNumber;
    isInitialBuild = true;
    attendeeOffset = 0;
    clickFlags = {
      "attending": false,
      "bookmark": false,
    };
    super.initState();
  }

  Future<bool> getEventDetails() async {
    await getEventAttendanceStatus();
    await firestore!
        .collection("events")
        .doc(widget.eventID)
        .get()
        .then((value) {
      if (value.data() != null) {
        if (value.data()!["peopleInEvent"] != null &&
            value.data()!["peopleInEvent"].isNotEmpty) {
          people.clear();
          value.data()!["peopleInEvent"].forEach((value) {
            people.add(value);
          });
        }
        if (value.data()!["gallery"] != null &&
            value.data()!["gallery"].isNotEmpty) {
          galleryUrls.clear();
          value.data()!["gallery"].forEach((value) {
            if (value.toString() != "") {
              galleryUrls.add(value.toString());
            }
          });
        }
        if (value.data()!["eventDescription"] != null) {
          description = value.data()!["eventDescription"];
        }
      }
    });

    List<Map<String, dynamic>> idList = [];
    for (int i = 0; i < people.length; i++) {
      if (people[i]["uid"] != null) {
        idList.add({"index": i, "uid": people[i]["uid"]});
      }
    }
    List<Map<String, dynamic>> idDetails = await getPeopleDetailsByID(idList);
    for (int i = 0; i < idDetails.length; i++) {
      int index = idDetails[i].remove("index");
      people[index] = idDetails[i];
    }

    gallery = getImagesFromLinks(galleryUrls);

    return true;
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
    if (idHolder.isEmpty) {
      return [];
    }
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
        dynamic phone;
        if (value["mobileContactNo"] != null &&
            value["mobileContactNo"] != "") {
          phone = value["mobileContactNo"];
        }
        String? position;
        if (value["currentDesignation"] != null &&
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
                eventDescription: description,
                eventDuration: widget.eventDuration.inHours,
                eventHolder: widget.eventHolder,
                eventLink: widget.eventLink,
                eventStartTime: widget.eventStartTime,
                eventTitle: widget.eventTitle,
                eventTitleImage: widget.eventTitleImage,
                gallery: galleryUrls,
                peopleInEvent: people,
                eventTitleImagePath: widget.eventTitleImagePath,
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
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage();
          } else if (snapshot.hasError) {
            print(snapshot.error);
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Scaffold _buildPage() {
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
                maxLines: 255,
                softWrap: false,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                "By: " + widget.eventHolder,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  // color: Colors.grey.shade300
                ),
                maxLines: 255,
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
    Widget bannerWidget;
    double bannerAreaHeight;
    if (widget.eventTitleImage != null) {
      bannerAreaHeight = screenHeight * 0.2;
      bannerWidget = GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return FullScreenImageViewer(
                child: [widget.eventTitleImage!], dark: true);
          })));
        },
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: widget.eventTitleImage!.image, fit: BoxFit.fitHeight)),
        ),
      );
    } else {
      bannerAreaHeight = 0;
      bannerWidget = const SizedBox();
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
    ];
    if (widget.eventLink != null &&
        Uri.tryParse(widget.eventLink!)!.hasAbsolutePath) {
      IconButton openLinkButton = IconButton(
          onPressed: () {
            launchUrl(Uri.parse(widget.eventLink!));
          },
          icon: const Icon(Icons.open_in_new));
      iconButtons.add(openLinkButton);
    }
    Widget eventOptions = iconButtons.isNotEmpty
        ? Container(
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
                )))
        : const SizedBox();
    if (userData["uid"] == null) {
      eventOptions = const SizedBox(
        height: 0,
      );
    }
    List<Widget> appBarActions = _setActionButtons();

    final List<Widget> tabViews = [
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(description)]),
      ListView.builder(
          shrinkWrap: true,
          itemCount: people.length,
          itemBuilder: ((context, index) {
            String subTitle = "";
            if (people[index]["description"] == null) {
              subTitle = "";
            } else {
              subTitle = people[index]["description"];
            }
            if (people[index]["name"] != null) {
              return Container(
                margin:
                    const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(4)),
                child: ListTile(
                  onTap: () {
                    if (people[index]["uid"] != null) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: ((context) {
                        return ProfilePage(uid: people[index]["uid"]);
                      })));
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PersonInEventPopUp(
                              name: people[index]["name"],
                              email: people[index]["email"],
                              description: people[index]["description"],
                              number: people[index]["number"],
                            );
                          });
                    }
                  },
                  title: Text(people[index]["name"]),
                  subtitle: Text(subTitle),
                ),
              );
            } else {
              return const SizedBox();
            }
          })),
      GridView.builder(
          shrinkWrap: true,
          itemCount: gallery.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            final Image image = gallery[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return FullScreenImageViewer(child: gallery, dark: true);
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
    ];

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            stretchTriggerOffset: 1,
            onStretchTrigger: () async {
              setState(() {});
            },
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            actions: const [SizedBox()],
            expandedHeight: bannerAreaHeight,
            flexibleSpace: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlexibleSpaceBar(background: bannerWidget),
            ),
          ),
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    DefaultTabController(
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
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor,
                                child: TabBar(
                                    onTap: (newSelectedTab) {
                                      setState(() {
                                        _selectedTab = newSelectedTab;
                                      });
                                    },
                                    indicatorColor: Theme.of(context)
                                        .floatingActionButtonTheme
                                        .backgroundColor,
                                    unselectedLabelColor: Theme.of(context)
                                        .appBarTheme
                                        .shadowColor!
                                        .withOpacity(0.6),
                                    labelColor: Theme.of(context)
                                        .appBarTheme
                                        .shadowColor,
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
                                padding:
                                    const EdgeInsets.fromLTRB(14, 10, 14, 2),
                                color: Theme.of(context).canvasColor,
                                child: tabViews[_selectedTab])
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonInEventPopUp extends StatelessWidget {
  final String name;
  final String? description;
  final String? number;
  final String email;
  const PersonInEventPopUp(
      {required this.name,
      this.description,
      this.number,
      required this.email,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: null,
      height: screenHeight * 0.48,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Dismiss"))
      ],
      content: Column(
        children: [
          GroupBox(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(name),
              title: "Name",
              titleBackground: Theme.of(context).canvasColor),
          GroupBox(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(description == null ? "-" : description!),
              title: "Description",
              titleBackground: Theme.of(context).canvasColor),
          GroupBox(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(number == null ? "-" : number!),
              title: "Number",
              titleBackground: Theme.of(context).canvasColor),
          GroupBox(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(email),
              title: "Email",
              titleBackground: Theme.of(context).canvasColor),
        ],
      ),
    );
  }
}
