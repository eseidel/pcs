// Explicitly separate from structures.dart to allow being included
// even when gen/items.dart is not available.

import 'units.dart';

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

// Unclear if this should be generated or explicit?
enum ItemType {
  equipment(false),
  bio(false),
  larva(false),
  butterfly(false),
  biomassspreader(true),
  ore(false),
  lamps(true),
  food(false),
  furniture(true),
  base(true),
  basemisc(true),
  craftingstation(true),
  drills(true),
  industrial(true),
  foodgrower(true),
  power(true),
  gasextractor(true),
  heaters(true),
  microchip(false),
  oreextractor(true),
  consumable(false),
  rocket(false),
  screen(true),
  seed(false),
  treeseed(false),
  vegetube(true),
  watercollector(true);

  // This is kind a hack.
  final bool isStructure;

  const ItemType(this.isStructure);

  // Just "equipment", not "ItemType.equipment".
  factory ItemType.fromName(String name) {
    var longName = "ItemType.$name";
    for (var type in ItemType.values) {
      if (type.toString() == longName) {
        return type;
      }
    }
    throw ArgumentError("Unknown ItemType: $name");
  }
}

// Structure might be a subclass at some point?
typedef Structure = Item;

class Item {
  final String key;
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

  const Item({
    required this.key,
    required this.type,
    required this.unlocksAt,
    required this.cost,
    required this.energy,
    required this.name,
    this.progress = const Progress(),
    this.description = "",
    required this.location,
  });
}
