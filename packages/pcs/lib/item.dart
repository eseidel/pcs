// Explicitly separate from structures.dart to allow being included
// even when gen/items.dart is not available.

import 'units.dart';

// In rust this would be an enum with differnt members for each variant.
// I don't think that's possible in Dart.
class Goal {
  final Ti? ti;
  final Pressure? pressure;
  final Heat? heat;
  final O2? oxygen;
  final Mass? plants;
  final Mass? insects;
  final Mass? biomass;

  String get type {
    if (ti != null) return 'ti';
    if (pressure != null) return 'pressure';
    if (heat != null) return 'heat';
    if (oxygen != null) return 'oxygen';
    if (plants != null) return 'plants';
    if (insects != null) return 'insects';
    if (biomass != null) return 'biomass';
    throw Exception('Goal has no type');
  }

  const Goal.ti(Ti this.ti)
      : oxygen = null,
        heat = null,
        pressure = null,
        plants = null,
        insects = null,
        biomass = null;

  const Goal.biomass(Mass this.biomass)
      : ti = null,
        oxygen = null,
        heat = null,
        pressure = null,
        plants = null,
        insects = null;

  const Goal.pressure(Pressure this.pressure)
      : ti = null,
        oxygen = null,
        heat = null,
        plants = null,
        insects = null,
        biomass = null;

  const Goal.heat(Heat this.heat)
      : ti = null,
        oxygen = null,
        pressure = null,
        plants = null,
        insects = null,
        biomass = null;

  const Goal.oxygen(O2 this.oxygen)
      : ti = null,
        heat = null,
        pressure = null,
        plants = null,
        insects = null,
        biomass = null;

  const Goal.plants(Mass this.plants)
      : ti = null,
        oxygen = null,
        heat = null,
        pressure = null,
        insects = null,
        biomass = null;

  const Goal.insects(Mass this.insects)
      : ti = null,
        oxygen = null,
        heat = null,
        pressure = null,
        plants = null,
        biomass = null;

  const Goal.zero()
      : ti = const Ti(0),
        oxygen = null,
        heat = null,
        pressure = null,
        plants = null,
        insects = null,
        biomass = null;

  bool get isZero => ti?.isZero ?? false;

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

    // Is this correct, it's an OR not an AND?
    if (biomass != null) {
      return totalProgress.biomass >= biomass!;
    } else if (plants != null) {
      return totalProgress.plants >= plants!;
    } else if (insects != null) {
      return totalProgress.insects >= insects!;
    } else {
      throw StateError('No goal specified');
    }
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
    } else if (plants != null) {
      return plants!.toTi();
    } else if (insects != null) {
      return insects!.toTi();
    } else if (biomass != null) {
      return biomass!.toTi();
    } else {
      throw StateError('No goal specified');
    }
  }

  @override
  String toString() {
    if (ti != null) {
      return ti.toString();
    } else if (oxygen != null) {
      return "$oxygen (${oxygen!})";
    } else if (heat != null) {
      return "$heat (${heat!})";
    } else if (pressure != null) {
      return "$pressure (${pressure!})";
    } else if (plants != null) {
      return "$plants (${plants!})";
    } else if (insects != null) {
      return "$insects (${insects!})";
    } else if (biomass != null) {
      return "$biomass (${biomass!})";
    } else {
      throw StateError('No goal specified');
    }
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
  plantspreader(true),
  insectspreader(true),
  ore(false),
  lamps(true),
  food(false),
  furniture(true),
  base(true),
  basemisc(true),
  craftingstation(true),
  drills(true),
  industrial(false),
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

// Split this into "ItemType" and "Recipe"?
// Items need to be instantiated in the world, as some have state.
class Item {
  final String key;
  final Goal unlocksAt;
  final int? microchipNumber;
  final List<Item> cost;
  final double energy;
  final Progress progress;
  final String name;
  final String description;
  final Location location;
  final ItemType type;

  bool isAvailable(Progress progress, int microchipCount) {
    if (microchipNumber != null) {
      return microchipCount >= microchipNumber!;
    }
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
    this.microchipNumber,
  });

  @override
  String toString() {
    return name;
  }
}
