import 'package:alumni/globals.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:flutter/material.dart';

class UserFilterPopUp extends StatefulWidget {
  final bool showAdmins;
  final bool showAlumni;
  final bool showStudents;
  final int typeFilterValue;
  final bool isAscendingOrder;
  final String? courseFilterValue;
  final int? admissionYearFilterValue;
  final String? nationalityFilterValue;
  final String? designationFilterValue;
  final String? organisationFilterValue;
  const UserFilterPopUp(
      {required this.showAdmins,
      required this.showAlumni,
      required this.showStudents,
      required this.typeFilterValue,
      required this.isAscendingOrder,
      required this.courseFilterValue,
      required this.admissionYearFilterValue,
      required this.nationalityFilterValue,
      required this.designationFilterValue,
      required this.organisationFilterValue,
      Key? key})
      : super(key: key);

  @override
  State<UserFilterPopUp> createState() => _UserFilterPopUpState();
}

class _UserFilterPopUpState extends State<UserFilterPopUp> {
  late bool _showAlumni;
  late bool _showStudents;
  late bool _showAdmins;
  late int _typeFilterValue;
  late bool _isAscendingOrder;
  late String? _courseFilterValue;
  late int? _admissionYearFilterValue;
  late String? _nationalityFilterValue;
  late String? _designationFilterValue;
  late String? _organisationFilterValue;
  @override
  void initState() {
    _organisationFilterValue = widget.organisationFilterValue;
    _designationFilterValue = widget.designationFilterValue;
    _nationalityFilterValue = widget.nationalityFilterValue;
    _admissionYearFilterValue = widget.admissionYearFilterValue;
    _courseFilterValue = widget.courseFilterValue;
    _isAscendingOrder = widget.isAscendingOrder;
    _typeFilterValue = widget.typeFilterValue;
    _showAdmins = widget.showAdmins;
    _showAlumni = widget.showAlumni;
    _showStudents = widget.showStudents;
    super.initState();
  }

  Future<bool> _getDesignationData() async {
    if (designationData == null) {
      designationData = {};

      await firestore!
          .collection("users")
          .where("currentDesignation", isNull: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          String currentDesignation = element.data()["currentDesignation"];
          if (currentDesignation != "") {
            if (designationData![currentDesignation] == null) {
              designationData![currentDesignation] = 1;
            } else {
              designationData![currentDesignation] =
                  designationData![currentDesignation]! + 1;
            }
          }
        }
      });
      return true;
    } else {
      return true;
    }
  }

  Future<bool> _getOrganisationData() async {
    if (organisationData == null) {
      organisationData = {};

      await firestore!
          .collection("users")
          .where("currentOrgName", isNull: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          String currentOrgName = element.data()["currentOrgName"];
          if (currentOrgName != "") {
            if (organisationData![currentOrgName] == null) {
              organisationData![currentOrgName] = 1;
            } else {
              organisationData![currentOrgName] =
                  organisationData![currentOrgName]! + 1;
            }
          }
        }
      });
      return true;
    } else {
      return true;
    }
  }

  Future<bool> _getCourseData() async {
    if (courseData == null) {
      courseData = {};
      await firestore!
          .collection("users")
          .where("course", isNull: false)
          .get()
          .then((value) {
        for (var e in value.docs) {
          String course = e.data()["course"];
          if (course != "") {
            if (courseData![course] == null) {
              courseData![course] = 1;
            } else {
              courseData![course] = courseData![course]! + 1;
            }
          }
        }
      });
      return true;
    } else {
      return true;
    }
  }

  Future<bool> _getAdmissionYearData() async {
    if (admissionYearData == null) {
      admissionYearData = {};
      await firestore!
          .collection("users")
          .where("admissionYear", isNull: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          int admissionYear = element.data()["admissionYear"];
          if (admissionYearData![admissionYear] == null) {
            admissionYearData![admissionYear] = 1;
          } else {
            admissionYearData![admissionYear] =
                admissionYearData![admissionYear]! + 1;
          }
        }
      });

      return true;
    } else {
      return true;
    }
  }

  Future<bool> _getNationalityData() async {
    if (nationalityData == null) {
      nationalityData = {};
      await firestore!
          .collection("users")
          .where("nationality", isNull: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          String nationality = element.data()["nationality"];
          if (nationality != "") {
            if (nationalityData![nationality] == null) {
              nationalityData![nationality] = 1;
            } else {
              nationalityData![nationality] =
                  nationalityData![nationality]! + 1;
            }
          }
        }
      });
      return true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.5),
            blurStyle: BlurStyle.normal,
            spreadRadius: 0.1,
            blurRadius: 0.5,
            offset: const Offset(0, 0),
          ),
        ],
        color: Theme.of(context).canvasColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .appBarTheme
                      .shadowColor!
                      .withOpacity(0.5),
                  blurStyle: BlurStyle.normal,
                  spreadRadius: 0.1,
                  blurRadius: 0.5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                RotatedBox(
                  quarterTurns: 1,
                  child: IconButton(
                      color: _isAscendingOrder == false
                          ? Theme.of(context).appBarTheme.foregroundColor
                          : Colors.grey,
                      splashRadius: 1,
                      onPressed: (() {
                        bool nextValue = true;
                        if (_isAscendingOrder) {
                          nextValue = false;
                        }
                        setState(() {
                          _isAscendingOrder = nextValue;
                        });
                      }),
                      icon: const Icon(Icons.compare_arrows_outlined)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: SizedBox(
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? screenHeight * 0.36
                      : screenHeight * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildByTypeFilter(),
                    _buildFilterByCourse(),
                    _buildFilterByAdmissionYear(),
                    _buildFilterByNationality(),
                    _builFilterByDesignation(),
                    _buildFilterByOrganisation(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: screenHeight * 0.06,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .appBarTheme
                      .shadowColor!
                      .withOpacity(0.5),
                  blurStyle: BlurStyle.normal,
                  spreadRadius: 0.1,
                  blurRadius: 0.5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        fixedSize: Size.fromWidth(screenWidth * 0.4)),
                    onPressed: () {
                      Navigator.of(context).pop({
                        "showAdmins": true,
                        "showAlumni": true,
                        "showStudents": true,
                        "typeFilterValue": 7,
                        "isAscendingOrder": true,
                        "designationFilterValue": null,
                        "nationalityFilterValue": null,
                        "organisationFilterValue": null,
                        "courseFilterValue": null,
                        "admissionYearFilterValue": null
                      });
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(fontSize: 16, color: Colors.deepOrange),
                    )),
                Container(
                  height: screenHeight * 0.06,
                  child: const Text(""),
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color:
                                  Theme.of(context).appBarTheme.shadowColor!))),
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        fixedSize: Size.fromWidth(screenWidth * 0.4)),
                    onPressed: () {
                      Navigator.of(context).pop({
                        "showAdmins": _showAdmins,
                        "showAlumni": _showAlumni,
                        "showStudents": _showStudents,
                        "typeFilterValue": _typeFilterValue,
                        "isAscendingOrder": _isAscendingOrder,
                        "designationFilterValue": _designationFilterValue,
                        "nationalityFilterValue": _nationalityFilterValue,
                        "organisationFilterValue": _organisationFilterValue,
                        "courseFilterValue": _courseFilterValue,
                        "admissionYearFilterValue": _admissionYearFilterValue
                      });
                    },
                    child: const Text(
                      "Filter",
                      style: TextStyle(fontSize: 16),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildByTypeFilter() {
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      title: "By Type",
      child: Container(
        height: screenHeight * 0.075,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                bool nextValue = true;
                int changeInChoiceValue = 0;
                if (_showStudents == true) {
                  nextValue = false;
                  changeInChoiceValue = -1;
                } else {
                  nextValue = true;
                  changeInChoiceValue = 1;
                }
                setState(() {
                  _showStudents = nextValue;
                  _typeFilterValue += changeInChoiceValue;
                });
              },
              child: Text(
                "Students",
                style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  onPrimary: Colors.transparent,
                  primary: _showStudents == true
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  side: BorderSide(
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.2)),
                  fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
            ),
            ElevatedButton(
              onPressed: () {
                bool nextValue = true;
                int changeInChoiceValue = 0;
                if (_showAlumni == true) {
                  nextValue = false;
                  changeInChoiceValue = -2;
                } else {
                  nextValue = true;
                  changeInChoiceValue = 2;
                }
                setState(() {
                  _showAlumni = nextValue;
                  _typeFilterValue += changeInChoiceValue;
                });
              },
              child: Text(
                "Alumni",
                style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  onPrimary: Colors.transparent,
                  primary: _showAlumni == true
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  side: BorderSide(
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.2)),
                  fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
            ),
            ElevatedButton(
              onPressed: () {
                int changeInChoiceValue = 0;

                bool nextValue = true;
                if (_showAdmins == true) {
                  nextValue = false;
                  changeInChoiceValue = -4;
                } else {
                  nextValue = true;
                  changeInChoiceValue = 4;
                }
                setState(() {
                  _showAdmins = nextValue;
                  _typeFilterValue += changeInChoiceValue;
                });
              },
              child: Text(
                "Admins",
                style: TextStyle(
                    fontSize: screenWidth * 0.027,
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  onPrimary: Colors.transparent,
                  primary: _showAdmins == true
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  side: BorderSide(
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.2)),
                  fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterByCourse() {
    return FutureBuilder(
        future: _getCourseData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  title: "By Course",
                  titleBackground: Theme.of(context).canvasColor,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        icon: null,
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _courseFilterValue,
                        style: const TextStyle(fontSize: 14),
                        items: courseData!.keys
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) =>
                                DropdownMenuItem<String>(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value,
                                          style: TextStyle(
                                              fontWeight:
                                                  value != _courseFilterValue
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                              color: value != _courseFilterValue
                                                  ? Theme.of(context)
                                                      .appBarTheme
                                                      .foregroundColor
                                                  : Colors.blue)),
                                      Text(courseData![value].toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .appBarTheme
                                                  .foregroundColor!
                                                  .withOpacity(0.75)))
                                    ],
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == _courseFilterValue) {
                            newValue = null;
                          }
                          setState(() {
                            _courseFilterValue = newValue;
                          });
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Widget _buildFilterByAdmissionYear() {
    return FutureBuilder(
        future: _getAdmissionYearData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  title: "By Year of Admission",
                  titleBackground: Theme.of(context).canvasColor,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<int?>(
                        dropdownColor: Theme.of(context).cardColor,
                        icon: null,
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _admissionYearFilterValue,
                        style: const TextStyle(fontSize: 14),
                        items: admissionYearData!.keys
                            .toList()
                            .map<DropdownMenuItem<int>>((int value) =>
                                DropdownMenuItem<int>(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value.toString(),
                                          style: TextStyle(
                                              fontWeight: value !=
                                                      _admissionYearFilterValue
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: value !=
                                                      _admissionYearFilterValue
                                                  ? Theme.of(context)
                                                      .appBarTheme
                                                      .foregroundColor
                                                  : Colors.blue)),
                                      Text(admissionYearData![value].toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .appBarTheme
                                                  .foregroundColor!
                                                  .withOpacity(0.75)))
                                    ],
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (int? newValue) {
                          if (newValue == _admissionYearFilterValue) {
                            newValue = null;
                          }
                          setState(() {
                            _admissionYearFilterValue = newValue;
                          });
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Widget _buildFilterByNationality() {
    return FutureBuilder(
        future: _getNationalityData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  title: "By Nationality",
                  titleBackground: Theme.of(context).canvasColor,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        dropdownColor: Theme.of(context).cardColor,
                        icon: null,
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _nationalityFilterValue,
                        style: const TextStyle(fontSize: 14),
                        items: nationalityData!.keys
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) =>
                                DropdownMenuItem<String>(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value,
                                          style: TextStyle(
                                              fontWeight: value !=
                                                      _nationalityFilterValue
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: value !=
                                                      _nationalityFilterValue
                                                  ? Theme.of(context)
                                                      .appBarTheme
                                                      .foregroundColor
                                                  : Colors.blue)),
                                      Text(nationalityData![value].toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .appBarTheme
                                                  .foregroundColor!
                                                  .withOpacity(0.75)))
                                    ],
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == _nationalityFilterValue) {
                            newValue = null;
                          }
                          setState(() {
                            _nationalityFilterValue = newValue;
                          });
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Widget _builFilterByDesignation() {
    return FutureBuilder(
        future: _getDesignationData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  title: "By Designation",
                  titleBackground: Theme.of(context).canvasColor,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        dropdownColor: Theme.of(context).cardColor,
                        icon: null,
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _designationFilterValue,
                        style: const TextStyle(fontSize: 14),
                        items: designationData!.keys
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(value,
                                    style: TextStyle(
                                        fontWeight:
                                            value != _designationFilterValue
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                        color: value != _designationFilterValue
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : Colors.blue)),
                                Text(designationData![value].toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .appBarTheme
                                            .foregroundColor!
                                            .withOpacity(0.75)))
                              ],
                            ),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue == _designationFilterValue) {
                            newValue = null;
                          }
                          setState(() {
                            _designationFilterValue = newValue;
                          });
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Widget _buildFilterByOrganisation() {
    return FutureBuilder(
        future: _getOrganisationData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  title: "By Organisation",
                  titleBackground: Theme.of(context).canvasColor,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                        dropdownColor: Theme.of(context).cardColor,
                        icon: null,
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _organisationFilterValue,
                        style: const TextStyle(fontSize: 14),
                        items: organisationData!.keys
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) =>
                                DropdownMenuItem<String>(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value,
                                          style: TextStyle(
                                              fontWeight: value !=
                                                      _organisationFilterValue
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: value !=
                                                      _organisationFilterValue
                                                  ? Theme.of(context)
                                                      .appBarTheme
                                                      .foregroundColor
                                                  : Colors.blue)),
                                      Text(organisationData![value].toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .appBarTheme
                                                  .foregroundColor!
                                                  .withOpacity(0.75)))
                                    ],
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == _organisationFilterValue) {
                            newValue = null;
                          }
                          setState(() {
                            _organisationFilterValue = newValue;
                          });
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }
}
