import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class BrakeTestTemplateItem_Provider {
  int _order = 1;
  String _dutName = "";
  String _type_of_brake = "";
  double _speed_min = 0.0;
  double _speed_max = 0.0;
  String _load_state = "leer";
  double _s_max = 0.0;
  double _a_min = 0.0;

  double asd = 0;
// Getter/Setter ===========================================================
  String get type_of_Brake {
    return _type_of_brake;
  }

  String get loadState {
    return _load_state;
  }

  // Load/Save ==============================================================
  Future<void> save() async {
    final myMap = toJson();

    try {
      final settingsJson = jsonEncode(myMap);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/BrakeTestTemplateItem.json');
      await file.writeAsString(settingsJson);
    } on Exception catch (e) {
      // TODO
    }
  }

  /*
 Future<void> loadSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Fahrzeuge.json');
      final json = await file.readAsString();
      final myMap = jsonDecode(json);
      fromJson_v2(myMap);

      try {} on Exception catch (e2) {
        print('Fehler beim Laden der Fahrzeuge..... $e2');
      }
    } on Exception catch (e) {
      // TODO
      print('Fehler beim Laden der Fahrzeuge.... $e');
    }
    notifyListeners();
  }
  */
  // Konstruktoren ==========================================================
  BrakeTestTemplateItem_Provider() {}
  BrakeTestTemplateItem_Provider.from(this._type_of_brake,
      {String dutName = "",
      double speed_min = 20,
      double speed_max = 25,
      double s_max = 20,
      double a_min = 1.1,
      String load_state = 'leer'}) {
    this._dutName = dutName;
    this._speed_min = speed_min;
    this._speed_max = speed_max;
    this._s_max = s_max;
    this._a_min = a_min;
    this._load_state = load_state;
  }

  // MAP/JSON =================================================================
  Map<String, dynamic> toJson() {
    return {
      'order': _order,
      'dutName': _dutName,
      'Type_of_Brake': _type_of_brake,
      'speed_min': _speed_min,
      'speed_max': _speed_max,
      'load_state': _load_state,
      's_max': _s_max,
      'a_min': _a_min
    };
  }

  // JSON ====================================================================
  factory BrakeTestTemplateItem_Provider.from_Json(Map<String, dynamic> json) {
    return BrakeTestTemplateItem_Provider()
      .._order = json['order']
      .._dutName = json['dutName']
      .._type_of_brake = json['Type_of_Brake']
      .._speed_min = json['speed_min']
      .._speed_max = json['speed_max']
      .._load_state = json['load_state']
      .._s_max = json['s_max']
      .._a_min = json['a_min'];
  }
  // 8

  //
}

class BrakeTestTemplate_Provider extends ChangeNotifier {
  List<BrakeTestTemplateItem_Provider> _list = [];

  List<BrakeTestTemplateItem_Provider> get ListOf => _list;

  void reorderTemplateItems(int oldindex, int newindex) {
    // dd
    if (oldindex < newindex) newindex--;

    final templateItem = _list.removeAt(oldindex);
    _list.insert(newindex, templateItem);

    notifyListeners();
  }

  BrakeTestTemplate_Provider() {
    _list.add(BrakeTestTemplateItem_Provider.from("SIFA",
        dutName: "5006-1",
        speed_min: 21,
        speed_max: 26,
        load_state: "leer",
        s_max: 19.90,
        a_min: 1.234));
    _list.add(BrakeTestTemplateItem_Provider.from("SIFA",
        dutName: "5006-8",
        speed_min: 21,
        speed_max: 26,
        load_state: "50kg",
        s_max: 19.90,
        a_min: 1.234));
    _list.add(BrakeTestTemplateItem_Provider.from("SIFA",
        dutName: "5006-1",
        speed_min: 21,
        speed_max: 26,
        load_state: "1250kg",
        s_max: 19.90,
        a_min: 1.234));
    _list.add(BrakeTestTemplateItem_Provider.from("Gefahrenbremsung",
        dutName: "5006-1",
        speed_min: 21,
        speed_max: 26,
        load_state: "1500kg",
        s_max: 19.90,
        a_min: 1.234));
    _list.add(BrakeTestTemplateItem_Provider.from("Ausfall einer Bremse",
        dutName: "5006-1",
        speed_min: 21,
        speed_max: 26,
        load_state: "1800kg",
        s_max: 19.90,
        a_min: 1.234));
    _list.add(BrakeTestTemplateItem_Provider.from("Fahrsperrenbremse",
        dutName: "5006-1",
        speed_min: 21,
        speed_max: 26,
        load_state: "2000kg",
        s_max: 19.90,
        a_min: 1.234));
  }
}

// Widget zum Anzeigen =======================================================
class TemplateList extends StatelessWidget {
  const TemplateList({super.key});
  void reorder(int oldindex, int newindex) {}
  @override
  Widget build(BuildContext context) {
    // Fahrzeuge fzg_provider = Provider.of<Fahrzeuge>(context, listen: false);
    BrakeTestTemplate_Provider bttp =
        Provider.of<BrakeTestTemplate_Provider>(context);

    return ReorderableListView(
      padding: const EdgeInsets.all(10),
      children: [
        for (final tile in bttp.ListOf)
          Padding(
            key: ValueKey(tile),
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey[200],
              child: ListTile(
                title: Text(tile.toString()),
              ),
            ),
          ),
      ],
      onReorder: (oldIndex, newIndex) {
        bttp.reorderTemplateItems(oldIndex, newIndex);
      },
    );
  }
}
