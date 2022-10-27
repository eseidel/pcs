// Not sure Items and Structures are actually separate?

import 'gen/items.dart';
export 'gen/items.dart';
import 'units.dart';
export 'units.dart';

enum Item {
  iron,
  iridium,
  ice,
  aluminium,
  cobalt,
  magnesium,
  silicon,
  superAlloy, // Mostly gated until later.
  titanium,
  water,
  osmium, // Gated until later.
  zeolite, // Gated until later.
  uranium, // Not gatherable.
  iridumRod, // Not gatherable.
  uraniumRod, // Not gatherable.
  pulsarQuartz, // Not gatherable.
  explosivePowder, // Not gatherable.
  fertilizer, // Not gatherable.
  fertilizerT2, // Not gatherable.
  bioplasticNugget, // Not gatherable.
  eggplant, // Not gatherable.
  bacteriaSample, // Not gatherable.
  treeBark, // Not gatherable.
  seedLirma, // Not reliably gatherable.
  // plant is kinda a hack, it's more of a "type" of item.
  plant, // Not reliably gatherable.
}

class ItemCounts {
  final List<int> _counts;

  // FIXME: Make this const
  ItemCounts() : _counts = List<int>.filled(Item.values.length, 0);

  factory ItemCounts.fromItems(List<Item> items) {
    var counts = List<int>.filled(Item.values.length, 0, growable: false);
    for (var item in items) {
      counts[item.index] += 1;
    }
    return ItemCounts._(counts);
  }

  ItemCounts._(this._counts);

  void adjust(Item item, int delta) {
    _counts[item.index] += delta;
  }

  int countOf(Item item) {
    return _counts[item.index];
  }

  bool operator <(ItemCounts other) {
    for (int i = 0; i < Item.values.length; i++) {
      if (_counts[i] >= other._counts[i]) {
        return false;
      }
    }
    return true;
  }

  bool operator <=(ItemCounts other) {
    for (int i = 0; i < Item.values.length; i++) {
      if (_counts[i] > other._counts[i]) {
        return false;
      }
    }
    return true;
  }

  ItemCounts operator +(ItemCounts other) {
    var newCounts = List<int>.from(_counts);
    for (int i = 0; i < Item.values.length; i++) {
      newCounts[i] += other._counts[i];
    }
    return ItemCounts._(newCounts);
  }

  ItemCounts operator -(ItemCounts other) {
    var newCounts = List<int>.from(_counts);
    for (int i = 0; i < Item.values.length; i++) {
      newCounts[i] -= other._counts[i];
    }
    return ItemCounts._(newCounts);
  }
}

// This is really an enum?
class Goal {
  final Ti? ti;
  final O2? oxygen;
  final Heat? heat;
  final Pressure? pressure;
  final Biomass? biomass;

  const Goal({this.ti, this.oxygen, this.heat, this.pressure, this.biomass});
  //  {
  //   assert([ti, oxygen, heat, pressure].where((e) e == null).length == 3);
  // }

  const Goal.zero()
      : ti = const Ti(0),
        oxygen = null,
        heat = null,
        pressure = null,
        biomass = null;

  bool wasReached(Progress totalProgress) {
    if (ti != null) {
      return totalProgress.ti >= ti!;
    } else if (oxygen != null) {
      return totalProgress.oxygen >= oxygen!;
    } else if (heat != null) {
      return totalProgress.heat >= heat!;
    } else if (pressure != null) {
      return totalProgress.pressure >= pressure!;
    }
    return totalProgress.biomass >= biomass!;
  }

  Ti toTi() {
    if (ti != null) {
      return ti!;
    } else if (oxygen != null) {
      return oxygen!.toTi();
    } else if (heat != null) {
      return heat!.toTi();
    } else if (pressure != null) {
      return pressure!.toTi();
    }
    return biomass!.toTi();
  }

  @override
  String toString() {
    if (ti != null) {
      return ti.toString();
    } else if (oxygen != null) {
      return "$oxygen (${oxygen!.toTi()})";
    } else if (heat != null) {
      return "$heat (${heat!.toTi()})";
    } else if (pressure != null) {
      return "$pressure (${pressure!.toTi()})";
    }
    return "$biomass (${biomass!.toTi()})";
  }
}

enum Location {
  outside,
  inside,
  // inventory, // Maybe if "Structures" and "Items" merge?
}

enum ItemType {
  industrial,
  bio,
  food,
  equiptment,
}

class Structure {
  final Goal unlocksAt;
  final List<Item> cost;
  final double energy;
  final Progress progress;
  final String name;
  final String description;
  final Location location;
  final ItemType type;

  bool isAvailable(Progress progress) {
    return unlocksAt.wasReached(progress);
  }

  const Structure({
    required this.unlocksAt,
    required this.cost,
    required this.energy,
    required this.name,
    this.progress = const Progress(),
    this.description = "",
    required this.location,
  }) : type = ItemType.industrial;

  String get key => name.replaceAll(' ', '').toLowerCase();
}

Structure strutureWithName(String name) {
  for (var structure in allStructures) {
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
