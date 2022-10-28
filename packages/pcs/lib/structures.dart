// Not sure Items and Structures are actually separate?

import 'item.dart';
export 'item.dart';
import 'gen/items.dart';
export 'gen/items.dart';
import 'units.dart';
export 'units.dart';

// If this were const, World could be const, but would need to be copy on write.
class ItemCounts {
  // FIXME: This could be faster than a map.
  final Map<Item, int> _counts;

  ItemCounts() : _counts = {};

  factory ItemCounts.fromItems(List<Item> items) {
    var counts = <Item, int>{};
    for (var item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return ItemCounts._(counts);
  }

  ItemCounts._(this._counts);

  void adjust(Item item, int delta) {
    _counts[item] = (_counts[item] ?? 0) + delta;
  }

  int countOf(Item item) {
    return _counts[item] ?? 0;
  }

  bool operator <(ItemCounts other) {
    for (var item in Items.all) {
      if (countOf(item) >= other.countOf(item)) {
        return false;
      }
    }
    return true;
  }

  bool operator <=(ItemCounts other) {
    for (var item in Items.all) {
      if (countOf(item) > other.countOf(item)) {
        return false;
      }
    }
    return true;
  }

  ItemCounts operator +(ItemCounts other) {
    var newCounts = Map<Item, int>.from(_counts);
    for (var item in Items.all) {
      newCounts[item] = (newCounts[item] ?? 0) + other.countOf(item);
    }
    return ItemCounts._(newCounts);
  }

  ItemCounts operator -(ItemCounts other) {
    var newCounts = Map<Item, int>.from(_counts);
    for (var item in Items.all) {
      newCounts[item] = (newCounts[item] ?? 0) - other.countOf(item);
    }
    return ItemCounts._(newCounts);
  }
}

Structure strutureWithName(String name) {
  for (var structure in Items.structures) {
    if (structure.name == name) {
      return structure;
    }
  }
  throw ArgumentError.value(name, "No structure with name");
}

class Stage {
  final String name;
  final Ti startsAt;
  const Stage(this.name, this.startsAt);
}

// FIXME: This could just be an enum?
// https://planet-crafter.fandom.com/wiki/Terraformation_stages
final stages = const <Stage>[
  Stage("Barren", Ti(0)),
  Stage("Blue Sky", Ti.kilo(175)),
  Stage("Clouds", Ti.kilo(350)),
  Stage("Rain", Ti.kilo(875)),
  Stage("Liquid Water", Ti.mega(3)),
  Stage("Lakes", Ti.mega(50)),
  Stage("Moss", Ti.mega(200)),
  Stage("Flora", Ti.mega(700)),
  Stage("Trees", Ti.giga(2)),
  Stage("Insects", Ti.giga(8)),
  Stage("Breathable Atmosphere", Ti.giga(100)),
  // Stage("Fish", Ti.tera(5)),
  // Stage("Amphibians", Ti.peta(30)),
];

Stage stageByName(String name) {
  for (var stage in stages) {
    if (stage.name == name) {
      return stage;
    }
  }
  throw ArgumentError.value(name, "No stage with name");
}
