import 'package:flutter/material.dart';

class FilterModalBottomSheet extends StatefulWidget {
  final int? currentFilter;
  const FilterModalBottomSheet({required this.currentFilter, Key? key})
      : super(key: key);

  @override
  State<FilterModalBottomSheet> createState() => _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends State<FilterModalBottomSheet> {
  final List<String> _filterOptions = [
    "Before a date",
    "On a date",
    "After a date",
    "Between two dates",
    "Show all"
  ];
  late int? _selectedFilter;

  @override
  void initState() {
    _selectedFilter = widget.currentFilter;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.5),
            blurStyle: BlurStyle.normal,
            spreadRadius: 0.1,
            blurRadius: 0.5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.maxFinite,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).appBarTheme.shadowColor!))),
            child: const Text(
              "Filter By Date:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              int value = 1;
              setState(() {
                _selectedFilter = value;
              });
              Navigator.of(context).pop(value);
            },
            leading: Radio<int>(
                value: 1,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop(value);
                }),
            title: Text(_filterOptions[0]),
          ),
          ListTile(
            onTap: () {
              int value = 2;
              setState(() {
                _selectedFilter = value;
              });
              Navigator.of(context).pop(value);
            },
            leading: Radio<int>(
                value: 2,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop(value);
                }),
            title: Text(_filterOptions[1]),
          ),
          ListTile(
            onTap: () {
              int value = 3;
              setState(() {
                _selectedFilter = value;
              });
              Navigator.of(context).pop(value);
            },
            leading: Radio<int>(
                value: 3,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop(value);
                }),
            title: Text(_filterOptions[2]),
          ),
          ListTile(
            onTap: () {
              int value = 4;
              setState(() {
                _selectedFilter = value;
              });
              Navigator.of(context).pop(value);
            },
            leading: Radio<int>(
                value: 4,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop(value);
                }),
            title: Text(_filterOptions[3]),
          ),
          ListTile(
            onTap: () {
              int value = 5;
              setState(() {
                _selectedFilter = value;
              });
              Navigator.of(context).pop(value);
            },
            leading: Radio<int>(
                value: 5,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop(value);
                }),
            title: Text(_filterOptions[4]),
          ),
        ],
      ),
    );
  }
}
