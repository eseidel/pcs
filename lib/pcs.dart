import "dart:math";

// FIXME: Could this be a fixed size array with enum access?
class Resources {
  final int aluminium;
  final int cobalt;
  final int ice;
  final int iridium;
  final int iron;
  final int magnesium;
  final int silicon;
  final int superAlloy;
  final int titanium;

  const Resources(
      {this.ice = 0,
      this.iridium = 0,
      this.iron = 0,
      this.aluminium = 0,
      this.cobalt = 0,
      this.magnesium = 0,
      this.silicon = 0,
      this.superAlloy = 0,
      this.titanium = 0});

  bool operator <(Resources other) {
    return aluminium < other.aluminium &&
        cobalt < other.cobalt &&
        ice < other.ice &&
        iridium < other.iridium &&
        iron < other.iron &&
        magnesium < other.magnesium &&
        silicon < other.silicon &&
        superAlloy < other.superAlloy &&
        titanium < other.titanium;
  }

  bool operator <=(Resources other) {
    return aluminium <= other.aluminium &&
        cobalt <= other.cobalt &&
        ice <= other.ice &&
        iridium <= other.iridium &&
        iron <= other.iron &&
        magnesium <= other.magnesium &&
        silicon <= other.silicon &&
        superAlloy <= other.superAlloy &&
        titanium <= other.titanium;
  }

  Resources operator +(Resources other) {
    return Resources(
      ice: ice + other.ice,
      iridium: iridium + other.iridium,
      iron: iron + other.iron,
      aluminium: aluminium + other.aluminium,
      cobalt: cobalt + other.cobalt,
      magnesium: magnesium + other.magnesium,
      silicon: silicon + other.silicon,
      superAlloy: superAlloy + other.superAlloy,
      titanium: titanium + other.titanium,
    );
  }

  Resources operator -(Resources other) {
    return Resources(
      ice: ice - other.ice,
      iridium: iridium - other.iridium,
      iron: iron - other.iron,
      aluminium: aluminium - other.aluminium,
      cobalt: cobalt - other.cobalt,
      magnesium: magnesium - other.magnesium,
      silicon: silicon - other.silicon,
      superAlloy: superAlloy - other.superAlloy,
      titanium: titanium - other.titanium,
    );
  }
}

class Availablility {
  const Availablility.always();
}

class Progress {
  final double pressure;
  final double oxygen;
  final double heat;
  final double biomass;

  const Progress(
      {this.pressure = 0, this.oxygen = 0, this.heat = 0, this.biomass = 0});

  int get terraformationIndex {
    return (pressure + oxygen + heat + biomass).truncate();
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
      pressure: pressure * timeDelta,
      oxygen: oxygen * timeDelta,
      heat: heat * timeDelta,
      biomass: biomass * timeDelta,
    );
  }
}

class Structure {
  final Availablility availablility;
  final Resources cost;
  final double energy;
  final Progress progress;
  final String name;
  final String description;

  bool isAvailable(World world) {
    return true;
  }

  Structure({
    required this.availablility,
    required this.cost,
    required this.energy,
    required this.name,
    this.progress = const Progress(),
    this.description = "",
  });
}

List allStructures = [
  Structure(
    name: "Drill T1",
    availablility: Availablility.always(),
    cost: Resources(titanium: 1, iron: 1),
    energy: -0.5,
    progress: Progress(pressure: 0.2),
  ),
  Structure(
    name: "Wind Turbine",
    availablility: Availablility.always(),
    cost: Resources(iron: 1),
    energy: 1.2,
  ),
  Structure(
    name: "Heater T1",
    availablility: Availablility.always(),
    cost: Resources(iron: 1, iridium: 1, silicon: 1),
    progress: Progress(heat: 0.3),
    energy: -1,
  ),
  Structure(
    name: "Vegetube T1",
    availablility: Availablility.always(),
    cost: Resources(iron: 1, ice: 1, magnesium: 1),
    progress: Progress(oxygen: 1.5),
    energy: -.35,
  ),
];

class World {
  final int time;
  final Progress progress;

  final List<Structure> structures;
  final Resources inventory;

  double get availableEnergy {
    return structures.fold(0, (total, structure) => total + structure.energy);
  }

  const World({
    required this.time,
    required this.progress,
    required this.structures,
    required this.inventory,
  });

  const World.empty()
      : time = 0,
        progress = const Progress(),
        structures = const <Structure>[],
        inventory = const Resources();

  World copyWith({
    int? time,
    Progress? progress,
    List<Structure>? structures,
    Resources? inventory,
  }) {
    return World(
      time: time ?? this.time,
      progress: progress ?? this.progress,
      structures: structures ?? this.structures,
      inventory: inventory ?? this.inventory,
    );
  }
}

class Action {
  final int time;
  const Action({required this.time});
}

class Gather extends Action {
  final Resources resource;

  const Gather({required this.resource, required int time}) : super(time: time);
}

class Build extends Action {
  final Structure structure;
  Build(this.structure) : super(time: 1);
}

abstract class Actor {
  Action chooseAction(Simulation sim);
}

class RandomActor extends Actor {
  Random random;

  RandomActor({int? seed}) : random = Random(seed);

  @override
  Action chooseAction(Simulation sim) {
    var availableActions = sim.availableActions.toList();
    if (availableActions.length == 1) {
      return availableActions.first;
    }
    return availableActions[random.nextInt(availableActions.length - 1)];
  }
}

class PreferBuild extends Actor {
  Random random;

  PreferBuild({int? seed}) : random = Random(seed);

  @override
  Action chooseAction(Simulation sim) {
    var availableActions = sim.availableActions.toList();

    for (var action in availableActions) {
      if (action is Build) {
        return action;
      }
    }
    if (availableActions.length == 1) {
      return availableActions.first;
    }
    return availableActions[random.nextInt(availableActions.length - 1)];
  }
}

class ValueActor {
  @override
  Action chooseAction(Simulation sim) {
    var availableActions = sim.availableActions.toList();


    for ( var structure in sim.)
    // Look through all available (not necessarily buildable) structure builds.
    // Calculate the time distance from goal at current pace.
    // Calculate the EV of a given build (time saved?)
    // Diff needs with available resources (including energy)
    // Divide ev between missing ingredients or buildable energy sources.
    // Recurse for a buildable energy source.
    // Setting ev(ingredient) = max(ev(structure) / # missing, ev(ingredient))
    // Sort actions by EV.
    // If equal, pick randomly.
  }
}

class SimulationResult {
  final World world;
  final List<Action> actionLog;

  SimulationResult(this.world, this.actionLog);
}

bool canAfford(Structure structure, double worldEnergy, Resources inventory) {
  if (structure.energy < 0 && worldEnergy < structure.energy.abs()) {
    return false;
  }
  return structure.cost <= inventory;
}

class Simulation {
  final World world;

  Simulation(this.world);

  Iterable<Gather> get gatherActions {
    // These could have time relative to position?
    return const <Gather>[
      // FIXME: incomplete.
      Gather(resource: Resources(iron: 1), time: 1),
      Gather(resource: Resources(titanium: 1), time: 1),
      Gather(resource: Resources(cobalt: 1), time: 1),
      Gather(resource: Resources(magnesium: 1), time: 1),
      Gather(resource: Resources(silicon: 1), time: 1),
      Gather(resource: Resources(iridium: 1), time: 1),
      Gather(resource: Resources(ice: 1), time: 1),
    ];
  }

  Iterable<Build> get unlockedStructureActions sync* {
    // All structures are currently unlocked.
    allStructures.map((structure) => Build(structure));
  }

  Iterable<Build> get affordableStructureActions sync* {
    var worldEnergy = world.availableEnergy;
    for (var structure in allStructures) {
      if (canAfford(structure, worldEnergy, world.inventory)) {
        yield Build(structure);
      }
    }
  }



  Iterable<Action> get availableActions {
    Iterable<Action> gathers = gatherActions;
    return gathers.followedBy(affordableStructureActions);
  }
}

World applyAction(Action action, World world) {
  // Progress time.

  var progress = world.structures.fold(Progress(),
          (Progress total, Structure structure) => total + structure.progress) *
      action.time.toDouble();

  var time = world.time + action.time;

  var inventory = world.inventory;
  var structures = world.structures;

  if (action is Gather) {
    inventory += action.resource;
  } else if (action is Build) {
    inventory -= action.structure.cost;
    structures = List<Structure>.from(structures)..add(action.structure);
  } else {
    throw ArgumentError.value(action, "Unsuported action");
  }
  return world.copyWith(
    inventory: inventory,
    structures: structures,
    time: time,
    progress: progress,
  );
}

SimulationResult simulate(
    World world, Actor actor, bool Function(World world) isComplete) {
  var sim = Simulation(world);
  var actionLog = <Action>[];
  var previousTime = world.time;
  var lastLogTime = world.time;
  var logFrequency = 10;

  while (!isComplete(world)) {
    var availableActions = sim.availableActions(world).toList();
    var action = actor.chooseAction(availableActions);
    world = applyAction(action, world);
    assert(previousTime < world.time);
    if (world.time > lastLogTime + logFrequency) {
      print("${world.time} : TI ${world.progress.terraformationIndex}");
      lastLogTime = world.time;
    }
    actionLog.add(action);
  }
  return SimulationResult(world, actionLog);
}
