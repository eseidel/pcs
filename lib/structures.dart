// Not sure Items and Structures are actually separate?
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
  plant, // Not reliably gatherable.
  uranium, // Not gatherable.
  iridumRod, // Not gatherable.
  uraniumRod, // Not gatherable.
  pulsarQuartz, // Not gatherable,
  explosivePowder, // Not gatherable,
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

class Availablility {
  const Availablility.always();
}

class Progress {
  final Pressure pressure;
  final O2 oxygen;
  final Heat heat;
  final double biomass;

  // Used by tests which need a progress where everything is unlocked.
  const Progress.allUnlocks()
      : pressure = const Pressure(double.maxFinite),
        oxygen = const O2(double.maxFinite),
        heat = const Heat(double.maxFinite),
        biomass = double.maxFinite;

  const Progress(
      {this.pressure = const Pressure.zero(),
      this.oxygen = const O2.zero(),
      this.heat = const Heat.zero(),
      this.biomass = 0});

  Ti get ti {
    return Ti(pressure.nPa + oxygen.ppq + heat.pK + biomass);
  }

  Progress operator +(Progress other) {
    return Progress(
      pressure: pressure + other.pressure,
      oxygen: oxygen + other.oxygen,
      heat: heat + other.heat,
      biomass: biomass + other.biomass,
    );
  }

  Progress operator *(double timeDelta) {
    return Progress(
      pressure: pressure.scaleBy(timeDelta),
      oxygen: oxygen.scaleBy(timeDelta),
      heat: heat.scaleBy(timeDelta),
      biomass: biomass * timeDelta,
    );
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write("$ti");
    buffer.write(" o2: $oxygen");
    buffer.write(" heat: $heat");
    buffer.write(" pressure: $pressure");
    buffer.write(" biomass: $biomass");
    return buffer.toString();
  }
}

class Ti {
  final double value;
  const Ti(this.value);
  const Ti.zero() : value = 0;

  const Ti.kilo(double kiloTi) : value = kiloTi * 1000;
  const Ti.mega(double megaTi) : value = megaTi * 1000000;
  const Ti.giga(double gigaTi) : value = gigaTi * 1000000000;
  const Ti.tera(double teraTi) : value = teraTi * 1000000000000;

  Ti operator +(Ti other) => Ti(value + other.value);
  Ti scaleBy(double multiplier) => Ti(value * multiplier);
  Ti operator *(Ti other) => Ti(value * other.value);
  bool operator >=(Ti other) => value >= other.value;

  @override
  String toString() {
    // FIXME: Automatically scale printed units.
    return "${value.toStringAsFixed(1)}ti";
  }
}

Ti kTi(double value) => Ti(value * 1000);

class O2 {
  final double ppq; // Parts per quadrillion? e-15?
  const O2(this.ppq);
  const O2.zero() : ppq = 0;
  O2 operator +(O2 other) => O2(ppq + other.ppq);
  O2 scaleBy(double multiplier) => O2(ppq * multiplier);
  O2 operator *(O2 other) => O2(ppq * other.ppq);
  bool operator >=(O2 other) => ppq >= other.ppq;

  @override
  String toString() {
    // FIXME: Automatically scale printed units.
    return "${ppq.toStringAsFixed(1)}ppq";
  }
}

// FIXME: Not sure this is correct.
O2 ppq(double value) => O2(value); // e-15
O2 ppt(double value) => O2(value * 1000); // e-12
O2 ppb(double value) => O2(value * 1000000); // e-9

class Heat {
  final double pK; // picokelvin?  e-12?
  const Heat(this.pK);
  const Heat.zero() : pK = 0;
  Heat operator +(Heat other) => Heat(pK + other.pK);
  Heat scaleBy(double multiplier) => Heat(pK * multiplier);
  Heat operator *(Heat other) => Heat(pK * other.pK);
  bool operator >=(Heat other) => pK >= other.pK;

  @override
  String toString() {
    // FIXME: Automatically scale printed units.
    return "${pK.toStringAsFixed(1)}pK";
  }
}

Heat pK(double value) => Heat(value); // picokelvin: e-12
Heat nK(double value) => Heat(value * 1000); // nanokelvin: e-9
Heat uK(double value) => Heat(value * 1000000); // microkelvin: e-6

class Pressure {
  final double nPa; // nanopascals e-9
  const Pressure(this.nPa);
  const Pressure.zero() : nPa = 0;
  Pressure operator +(Pressure other) => Pressure(nPa + other.nPa);
  Pressure scaleBy(double multiplier) => Pressure(nPa * multiplier);
  Pressure operator *(Pressure other) => Pressure(nPa * other.nPa);
  bool operator >=(Pressure other) => nPa >= other.nPa;

  @override
  String toString() {
    // FIXME: Automatically scale printed units.
    return "${nPa.toStringAsFixed(1)}nPa";
  }
}

Pressure nPa(double value) => Pressure(value); // nanopascals: e-9
Pressure uPa(double value) => Pressure(value * 1000); // micropascals: e-6
Pressure mPa(double value) => Pressure(value * 1000); // millipascals: e-3

// This is really an enum?
class Goal {
  final Ti? ti;
  final O2? oxygen;
  final Heat? heat;
  final Pressure? pressure;

  const Goal({this.ti, this.oxygen, this.heat, this.pressure});
  //  {
  //   assert([ti, oxygen, heat, pressure].where((e) e == null).length == 3);
  // }

  const Goal.zero()
      : ti = const Ti(0),
        oxygen = null,
        heat = null,
        pressure = null;

  bool wasReached(Progress totalProgress) {
    if (ti != null) {
      return totalProgress.ti >= ti!;
    } else if (oxygen != null) {
      return totalProgress.oxygen >= oxygen!;
    } else if (heat != null) {
      return totalProgress.heat >= heat!;
    }
    return totalProgress.pressure >= pressure!;
  }
}

class Structure {
  final Goal unlocksAt;
  final List<Item> cost;
  final double energy;
  final Progress progress;
  final String name;
  final String description;

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
  });
}

// FIXME: Make this const.
final allStructures = <Structure>[
  Structure(
    name: "Drill T1",
    unlocksAt: Goal.zero(),
    cost: [Item.titanium, Item.iron],
    energy: -0.5,
    progress: Progress(pressure: nPa(0.2)),
  ),
  Structure(
    name: "Wind Turbine",
    unlocksAt: Goal.zero(),
    cost: [Item.iron],
    energy: 1.2,
  ),
  Structure(
    name: "Heater T1",
    unlocksAt: Goal.zero(),
    cost: [Item.iron, Item.iridium, Item.silicon],
    progress: Progress(heat: pK(0.3)),
    energy: -1,
  ),
  Structure(
    name: "Vegetube T1",
    unlocksAt: Goal.zero(),
    cost: [Item.iron, Item.ice, Item.magnesium, Item.plant],
    progress: Progress(oxygen: ppq(0.15)),
    energy: -.35,
  ),

  // Backpack T2 - 300 Ti
  // Solar Panel T1 - 1.0 kTi
  Structure(
    name: "Solar Panel T1",
    unlocksAt: Goal(ti: kTi(1.0)),
    cost: [Item.iron, Item.cobalt, Item.cobalt, Item.silicon],
    energy: 6.5,
  ),

  // Backpack T3 - 2.5 kTi
  // Solar Panel T2 - 17.5 kTi
  Structure(
    name: "Solar Panel T2",
    unlocksAt: Goal(ti: kTi(17.5)),
    cost: [
      Item.iron,
      Item.magnesium,
      Item.silicon,
      Item.cobalt,
      Item.cobalt,
      Item.aluminium
    ],
    energy: 19.5,
  ),

  // Double Bed - 25.0 kTi
  // Locker Storage - 50.0 kTi
  // Advanced Craft Station - 175 kTi
  // Launch Platform - 345.00 kTi
  // Backpack T5 - 5.00 MTi
  // Lake Water Collector - 50.00 MTi
  // Pulsar Quartz - 600.00 MTi
  // Seeds Spreader Rocket - 650.00 MTi
  // Water Filter - 1.00 GTi
  // Tree Spreader T3 - 79.50 GTi
  // Fusion Energy Cell - 578.56 GTi

  // Indoor Ladder - 1 ppt o2
  // Heater T2 - 1.85 ppt o2
  Structure(
    name: "Heater T2",
    unlocksAt: Goal(oxygen: ppt(1.85)),
    cost: [
      Item.iridium,
      Item.iridium,
      Item.silicon,
      Item.titanium,
      Item.iron,
      Item.aluminium
    ],
    progress: Progress(heat: pK(4.5)),
    energy: -3.5,
  ),

  // Oxygen Tank T3 - 5 ppt o2
  // Food Grower - 12 ppt o2
  // Vegetube T3 - 30 ppt o2
  Structure(
    name: "Vegetube T3",
    unlocksAt: Goal(oxygen: ppt(30)),
    cost: [
      Item.water,
      Item.silicon,
      Item.silicon,
      Item.magnesium,
      Item.aluminium
    ],
    progress: Progress(oxygen: ppq(13.0)),
    energy: -7.25,
  ),

  // Heater T3 - 80 ppt o2
  // Grass Spreader - 150.0 ppt o2
  // Flower Pot - 420.00 ppt
  // Tree Spreader T2 - 7.50 ppm

  // Vegetube T2 - 500 pK
  Structure(
    name: "Vegetube T2",
    unlocksAt: Goal(heat: pK(500)),
    cost: [Item.iron, Item.ice, Item.ice, Item.magnesium, Item.silicon],
    progress: Progress(oxygen: ppq(1.2)),
    energy: -1.25,
  ),

  // Screen - Progress - 2.0 nK
  // Beacon - 5.0 nK
  // Exoskeleton T2 - 10.0 nK
  // Drill T3 - 21 nK
  Structure(
    name: "Drill T3",
    unlocksAt: Goal(heat: nK(21)),
    cost: [
      Item.iron,
      Item.iron,
      Item.titanium,
      Item.titanium,
      Item.aluminium,
      Item.aluminium
    ],
    progress: Progress(heat: pK(2.5), pressure: nPa(17)),
    energy: -8.5,
  ),
  // Biodome - 100.0 nK
  // Sign - 500.0 nK
  // Algae Generator T1 - 2.00 uK
  // Biodome T2 - 12.00 uK
  // Drill T4 - 41.00 uK
  Structure(
    name: "Drill T4",
    unlocksAt: Goal(heat: uK(41)),
    cost: [
      Item.superAlloy,
      Item.superAlloy,
      Item.superAlloy,
      Item.osmium,
      Item.osmium,
      Item.osmium,
      Item.superAlloy,
      Item.superAlloy,
      Item.superAlloy,
    ],
    progress: Progress(heat: pK(25), pressure: nPa(459)),
    energy: -45,
  ),
  // Nuclear Fusion Generator - 750.00 uK
  Structure(
    name: "Nuclear Fusion Generator",
    unlocksAt: Goal(heat: uK(750)),
    cost: [
      Item.pulsarQuartz,
      Item.superAlloy,
      Item.pulsarQuartz,
      Item.superAlloy,
      Item.pulsarQuartz,
      Item.superAlloy,
      Item.pulsarQuartz,
      Item.superAlloy,
      Item.pulsarQuartz
    ],
    energy: 1835,
  ),

  // Oxygen Tank T2 - 70 nPa
  // Living Compartment Window - 250 nPa
  // Drill T2 - 1.20 uPa
  Structure(
    name: "Drill T2",
    unlocksAt: Goal(pressure: uPa(1.2)),
    cost: [Item.iron, Item.titanium, Item.titanium],
    progress: Progress(heat: pK(0.1), pressure: nPa(1.5)),
    energy: -5,
  ),
  // Living Compartment Glass - 4.0 uPa
  // Communication Antenna - 4.0 uPa
  // Screen - Transmissions - 4.0 uPa
  // Nuclear Reactor T1 - 60.0 uPa
  Structure(
    name: "Nuclear Reactor T1",
    unlocksAt: Goal(pressure: uPa(60)),
    cost: [
      Item.superAlloy,
      Item.superAlloy,
      Item.superAlloy,
      Item.water,
      Item.water,
      Item.uraniumRod,
    ],
    energy: 86.5,
  ),
  // Ore Extractor - 155.00 uPa
  // Nuclear Reactor T2 - 1.5 mPa
  Structure(
    name: "Nuclear Reactor T2",
    unlocksAt: Goal(pressure: mPa(1.5)),
    cost: [
      Item.water,
      Item.water,
      Item.water,
      Item.superAlloy,
      Item.uraniumRod,
      Item.uraniumRod,
      Item.uraniumRod,
      Item.explosivePowder,
    ],
    energy: 331.5,
  ),
  // Flower Spreader - 2.50 mPa
  // Gas Extractor - 100.00 mPa
  // Ore Extractor T2 - 364.50 mPa
];

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

// FIXME: Check these numbers.
// https://planet-crafter.fandom.com/wiki/Category:Terraformation
final stages = const <Stage>[
  Stage("Barren", Ti(0)),
  Stage("Blue Sky", Ti.kilo(175)),
  Stage("Clouds", Ti.mega(1)),
  // Stage("Rain", Ti(0)), // ???
  // Stage("Liquid Water", Ti(0)), // ???
  Stage("Lakes", Ti.mega(50)),
  Stage("Moss", Ti.mega(200)),
  // Stage("Flora", Ti(0)), // ???
  Stage("Trees", Ti.giga(3)),
  Stage("Insects", Ti.tera(1)),
];

Stage stageByName(String name) {
  for (var stage in stages) {
    if (stage.name == name) {
      return stage;
    }
  }
  throw ArgumentError.value(name, "No stage with name");
}
