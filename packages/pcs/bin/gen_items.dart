/// Generate items.dart from items.csv

import 'dart:io';

import 'package:pcs/item.dart';

extension TakeExtension<E> on Iterator<E> {
  E? takeOne() {
    if (moveNext()) {
      return current;
    }
    return null;
  }
}

class Entry {
  Map<String, String> fields = {};
  Entry(this.fields);

  // This class exists to cause generation code to fail if/when the
  // header names change.
  String operator [](String key) {
    var value = fields[key];
    if (value == null) {
      throw Exception('Unknown field: $key');
    }
    return value;
  }
}

List<Entry> _readCSV(String path) {
  var file = File(path);
  var lines = file.readAsLinesSync();
  var linesIter = lines.iterator;
  var header = linesIter.takeOne()!.split(',');
  var result = <Entry>[];
  while (linesIter.moveNext()) {
    var fields = <String, String>{};
    int index = 0;
    for (var value in linesIter.current.split(',')) {
      fields[header[index]] = value;
      index++;
    }
    result.add(Entry(fields));
  }
  return result;
}

class IntentingBuffer {
  StringBuffer buffer;
  int indentLevel;

  IntentingBuffer()
      : buffer = StringBuffer(),
        indentLevel = 0;

  void indent() {
    indentLevel++;
  }

  void unindent() {
    indentLevel--;
  }

  void writeln([String text = '']) {
    if (text.isEmpty) {
      buffer.writeln();
    } else {
      buffer.writeln('${'  ' * indentLevel}$text');
    }
  }

  @override
  String toString() => buffer.toString();
}

void main() {
  var items = _readCSV('items.csv');
  items.sort((a, b) => a['key'].compareTo(b['key']));
  var file = File('lib/gen/items.dart');
  var buffer = IntentingBuffer();

// key,name,type,power,oxygen,plants,insects,heat,pressure,dependency_1,dependency_2,dependency_3,dependency_4,dependency_5,dependency_6,dependency_7,dependency_8,dependency_9

  buffer.writeln("// Generated by bin/gen_items.dart");
  buffer.writeln("// Do not edit this file directly.");
  buffer.writeln();
  buffer.writeln("import 'package:pcs/structures.dart';");
  buffer.writeln();
  buffer.writeln('class Items {');
  buffer.indent();

  for (var item in items) {
    buffer.writeln('static const ${item['key']} = Item(');
    buffer.writeln('  key: \'${item['key']}\',');
    buffer.writeln('  name: \'${item['name']}\',');
    buffer.writeln('  type: ItemType.${item['type']},');
    var energy = item['power'].isEmpty ? '0.0' : item['power'];
    buffer.writeln('  energy: $energy,');
    if (['oxygen', 'plants', 'insects', 'heat', 'pressure']
        .any((key) => item[key].isNotEmpty)) {
      buffer.writeln('  progress: Progress(');
      if (item['oxygen'].isNotEmpty) {
        buffer.writeln('    oxygen: O2.ppq(${item['oxygen']}),');
      }
      if (item['plants'].isNotEmpty) {
        buffer.writeln('    plants: Mass.g(${item['plants']}),');
      }
      if (item['insects'].isNotEmpty) {
        buffer.writeln('    insects: Mass.g(${item['insects']}),');
      }
      if (item['heat'].isNotEmpty) {
        buffer.writeln('    heat: Heat.pK(${item['heat']}),');
      }
      if (item['pressure'].isNotEmpty) {
        buffer.writeln('    pressure: Pressure.nPa(${item['pressure']}),');
      }
      buffer.writeln('  ),');
    }

    if (item['dependency_1'].isNotEmpty) {
      buffer.writeln('  cost: [');
      for (var i = 1; i <= 9; i++) {
        var key = item['dependency_$i'];
        if (key.isEmpty) {
          break;
        }
        buffer.writeln('    Items.$key,');
      }
      buffer.writeln('  ],');
    } else {
      buffer.writeln('  cost: [],');
    }

    if (item['unlock_ti'].isNotEmpty) {
      buffer.writeln('  unlocksAt: Goal.ti(Ti(${item['unlock_ti']})),');
    } else if (item['unlock_biomass'].isNotEmpty) {
      buffer.writeln(
          '  unlocksAt: Goal.biomass(Mass.g(${item['unlock_biomass']})),');
    } else if (item['unlock_oxygen'].isNotEmpty) {
      buffer.writeln(
          '  unlocksAt: Goal.oxygen(O2.ppq(${item['unlock_oxygen']})),');
    } else if (item['unlock_plants'].isNotEmpty) {
      buffer.writeln(
          '  unlocksAt: Goal.plants(Mass.g(${item['unlock_plants']})),');
    } else if (item['unlock_insects'].isNotEmpty) {
      buffer.writeln(
          '  unlocksAt: Goal.insects(Mass.g(${item['unlock_insects']})),');
    } else if (item['unlock_heat'].isNotEmpty) {
      buffer
          .writeln('  unlocksAt: Goal.heat(Heat.pK(${item['unlock_heat']})),');
    } else if (item['unlock_pressure'].isNotEmpty) {
      buffer.writeln(
          '  unlocksAt: Goal.pressure(Pressure.nPa(${item['unlock_pressure']})),');
    } else {
      buffer.writeln('  unlocksAt: Goal.zero(),');
    }

    // FIXME: Location placement data is missing from the csv.
    buffer.writeln('  location: Location.outside,');

    buffer.writeln(');');
    buffer.writeln();
  }
  buffer.unindent();

  buffer.writeln('  static const all = [');
  for (var item in items) {
    buffer.writeln('    ${item['key']},');
  }
  buffer.writeln('  ];');

  buffer.writeln();
  buffer.writeln('  static const structures = [');
  for (var item in items) {
    var type = ItemType.fromName(item['type']);
    if (type.isStructure) {
      buffer.writeln('    ${item['key']},');
    }
  }
  buffer.writeln('  ];');

  buffer.writeln('}'); // close Items class.

  file.writeAsStringSync(buffer.toString());
}
