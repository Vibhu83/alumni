import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/confirmation_popup.dart';
import 'package:alumni/widgets/full_screen_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatefulWidget {
  final String eventID;
  final Image? eventTitleImage;
  final String? eventTitleImagePath;
  final String eventTitle;
  final String eventHolder;
  final DateTime eventStartTime;
  final int eventDuration;
  final String? eventLink;
  final bool readOnly;
  const AnEventPage(
      {required this.eventID,
      this.eventTitleImage,
      this.eventTitleImagePath,
      required this.eventTitle,
      required this.eventHolder,
      required this.eventStartTime,
      required this.eventDuration,
      this.eventLink,
      this.readOnly = false,
      Key? key})
      : super(key: key);

  @override
  State<AnEventPage> createState() => _AnEventPageState();
}

class _AnEventPageState extends State<AnEventPage> {
  late Map<String, bool> _clickFlags;
  late bool _isInitialBuild;
  late int _attendees;
  late List<Map<String, dynamic>> _people;
  late String _description;
  late List<Image> _gallery;
  late List<String> _galleryUrls;
  late int _selectedTab;

  @override
  void initState() {
    _selectedTab = 0;
    _galleryUrls = [];
    _people = [];
    _gallery = [];
    _description = "";
    _attendees = 0;
    _isInitialBuild = true;
    _clickFlags = {
      "attending": false,
      "bookmark": false,
    };
    if (userData["eventsBookmarked"] != null) {
      _clickFlags["bookmark"] =
          userData["eventsBookmarked"].contains(widget.eventID);
    }
    super.initState();
  }

  Future<bool> _getEventDetails() async {
    await _getEventAttendanceStatus();
    await firestore!
        .collection("events")
        .doc(widget.eventID)
        .get()
        .then((value) {
      if (value.data() != null) {
        if (value.data()!["peopleInEvent"] != null &&
            value.data()!["peopleInEvent"].isNotEmpty) {
          _people.clear();
          value.data()!["peopleInEvent"].forEach((value) {
            _people.add(value);
          });
        }
        if (value.data()!["gallery"] != null &&
            value.data()!["gallery"].isNotEmpty) {
          _galleryUrls.clear();
          value.data()!["gallery"].forEach((value) {
            if (value.toString() != "") {
              _galleryUrls.add(value.toString());
            }
          });
        }
        if (value.data()!["eventDescription"] != null) {
          _description = value.data()!["eventDescription"];
        }
      }
    });

    List<Map<String, dynamic>> idList = [];
    for (int i = 0; i < _people.length; i++) {
      if (_people[i]["uid"] != null) {
        idList.add({"index": i, "uid": _people[i]["uid"]});
      }
    }
    List<Map<String, dynamic>> idDetails = await _getPeopleDetailsByID(idList);
    for (int i = 0; i < idDetails.length; i++) {
      int index = idDetails[i].remove("index");
      _people[index] = idDetails[i];
    }

    _gallery = _getImagesFromLinks(_galleryUrls);

    return true;
  }

  List<Image> _getImagesFromLinks(List<String> links) {
    List<Image> galleryImages = [];
    for (String link in links) {
      galleryImages.add(Image.network(link));
    }
    return galleryImages;
  }

  Future<List<Map<String, dynamic>>> _getPeopleDetailsByID(
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
        String? position;
        if (value["currentDesignation"] != null &&
            value["currentOrgName"] != null) {
          position =
              value["currentDesignation"] + " at " + value["currentOrgName"];
        }
        return {
          "uid": value["uid"],
          "index": idHolder[count]["index"],
          "name": value["name"],
          "description": position,
        };
      }).toList();
    });
    return details;
  }

  Future<bool?> _getEventAttendanceStatus() async {
    if (_isInitialBuild && userData["uid"] != null) {
      _isInitialBuild = false;
      _attendees = await firestore!
          .collection("events")
          .doc(widget.eventID)
          .get()
          .then((value) => value.data()!["eventAttendeesNumber"]);
      bool? isBeingAttended = await firestore!
          .collection("eventAttendanceStatus")
          .doc(userData["uid"])
          .get()
          .then((value) {
        return value.data()![widget.eventID];
      });
      isBeingAttended ??= false;
      _clickFlags["attending"] = isBeingAttended;
      return true;
    } else {
      return true;
    }
  }

  void setBookmark() {
    List eventsBookmarked = userData["eventsBookmarked"];
    eventsBookmarked.add(widget.eventID);

    userData["eventsBookmarked"] = eventsBookmarked;

    firestore!
        .collection("users")
        .doc(userData["uid"])
        .update({"eventsBookmarked": eventsBookmarked});
  }

  void unsetBookmark() {
    List eventsBookmarked = userData["eventsBookmarked"];
    eventsBookmarked.remove(widget.eventID);

    userData["eventsBookmarked"] = eventsBookmarked;

    firestore!
        .collection("users")
        .doc(userData["uid"])
        .update({"eventsBookmarked": eventsBookmarked});
  }

  void _changeAttendeeNumber() async {
    bool nextAttendingFlag = false;
    int nextAttendeeNum = 0;
    int changeInAttendeeNum = 0;
    if (_clickFlags["attending"] == true) {
      nextAttendingFlag = false;
      changeInAttendeeNum = -1;
    } else {
      nextAttendingFlag = true;
      changeInAttendeeNum = 1;
    }
    nextAttendeeNum = _attendees + changeInAttendeeNum;
    setState(() {
      _attendees = nextAttendeeNum;
      _clickFlags["attending"] = nextAttendingFlag;
      lastEventAttendeesNumber = nextAttendeeNum;
      lastEventAttendeeChange = changeInAttendeeNum;
      lastEventBool = _clickFlags["attending"];
    });
  }

  void _deleteEvent() {
    showDialog(
        context: context,
        builder: (context) {
          return const ConfirmationPopUp(
            title: "Are you sure you want to delete the event?",
          );
        }).then((value) {
      if (value == true) {
        firestore!.collection("events").doc(widget.eventID).delete();
        deleteStorageFolder(widget.eventID);
        firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedItemID", isEqualTo: widget.eventID)
            .get()
            .then((value) {
          for (var element in value.docs) {
            if (element.data()["recommendationType"] == "event") {
              firestore!
                  .collection("recommendationFromAdmins")
                  .doc(element["recommendationID"])
                  .delete();
            }
          }
        });
        firestore!
            .collection("eventAttendanceStatus")
            .where(widget.eventID, isNotEqualTo: null)
            .get()
            .then((value) {
          for (var element in value.docs) {
            firestore!
                .collection("eventAttendanceStatus")
                .doc(element.id)
                .update({widget.eventID: FieldValue.delete()});
          }
        });
        String id = widget.eventID;
        List temp = userData["eventsBookmarked"];
        temp.remove(id);
        userData["eventsBookmarked"] = temp;
        firestore!
            .collection("users")
            .where("eventsBookmarked", arrayContains: id)
            .get()
            .then((value) {
          for (var element in value.docs) {
            List? temp = element.data()["eventsBookmarked"];
            if (temp != null) {
              temp.remove(id);
              firestore!
                  .collection("users")
                  .doc(element.id)
                  .update({"eventsBookmarked": temp});
            }
          }
        });
        Navigator.pop(context, -1);
      }
    });
  }

  List<Widget> _setActionButtons() {
    List<Widget> appBarActions = [];
    if (userData["hasAdminAccess"] == true) {
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
                eventDescription: _description,
                eventDuration: widget.eventDuration,
                eventHolder: widget.eventHolder,
                eventAttendeeNumber: _attendees,
                eventLink: widget.eventLink,
                eventStartTime: widget.eventStartTime,
                eventTitle: widget.eventTitle,
                eventTitleImage: widget.eventTitleImage,
                gallery: _galleryUrls,
                peopleInEvent: _people,
                eventTitleImagePath: widget.eventTitleImagePath,
                readOnly: widget.readOnly,
              );
            }));
          },
          icon: Icons.edit);
      appBarActions.add(editButton);
      IconButton deleteButton = buildAppBarIcon(
          onPressed: () {
            _deleteEvent();
          },
          icon: Icons.delete_rounded);
      appBarActions.add(deleteButton);
    }
    return appBarActions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getEventDetails(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage();
          } else if (snapshot.hasError) {
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
    if (_clickFlags["bookmark"] == true) {
      bookMarkIcon = Icons.bookmark_added;
      bookMarkIconColor = Colors.blue;
    }
    if (_clickFlags["attending"] == true) {
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
                    _attendees.toString(),
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
                          widget.eventDuration.toString() +
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
    List<Widget> iconButtons = [];
    if (widget.readOnly == false) {
      iconButtons.addAll([
        IconButton(
            splashRadius: 1,
            onPressed: () {
              _changeAttendeeNumber();
              changeAttendeeNumberInDB(widget.eventID);
            },
            icon: Icon(
              attendingIcon,
              color: attendingIconColor,
            )),
        IconButton(
            splashRadius: 1,
            onPressed: () {
              if (_clickFlags["bookmark"] == true) {
                unsetBookmark();
                setState(() {
                  _clickFlags["bookmark"] = false;
                });
              } else {
                setBookmark();
                setState(() {
                  _clickFlags["bookmark"] = true;
                });
              }
            },
            icon: Icon(
              bookMarkIcon,
              color: bookMarkIconColor,
            )),
      ]);
    }

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
    List<Widget> appBarActions = _setActionButtons();

    final List<Widget> tabViews = [
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(_description))
          ]),
      ListView.builder(
          shrinkWrap: true,
          itemCount: _people.length,
          itemBuilder: ((context, index) {
            String subTitle = "";
            if (_people[index]["description"] == null) {
              subTitle = "";
            } else {
              subTitle = _people[index]["description"];
            }
            if (_people[index]["name"] != null) {
              return Container(
                margin:
                    const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(4)),
                child: ListTile(
                  onTap: () {
                    if (_people[index]["uid"] != null) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: ((context) {
                        return ProfilePage(uid: _people[index]["uid"]);
                      })));
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PersonInEventPopUp(
                              name: _people[index]["name"],
                              email: _people[index]["email"],
                              description: _people[index]["description"],
                              number: _people[index]["number"],
                            );
                          });
                    }
                  },
                  title: Text(_people[index]["name"]),
                  subtitle: Text(subTitle),
                ),
              );
            } else {
              return const SizedBox();
            }
          })),
      GridView.builder(
          shrinkWrap: true,
          itemCount: _gallery.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            final Image image = _gallery[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return FullScreenImageViewer(child: _gallery, dark: true);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
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
          ];
        },
        body: ClipRRect(
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
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
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
                            child: tabViews[_selectedTab])
                      ],
                    )),
              ],
            ),
          ),
        ),
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
