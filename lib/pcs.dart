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

  double get terraformationIndex {
    return pressure + oxygen + heat + biomass;
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
  final Progress totalProgress;

  final List<Structure> structures;
  final Resources inventory;

  double get availableEnergy {
    return structures.fold(0, (total, structure) => total + structure.energy);
  }

  const World({
    required this.time,
    required this.totalProgress,
    required this.structures,
    required this.inventory,
  });

  Progress get progressPerSecond {
    // This does not handle the case of insufficient energy.
    return structures.fold(Progress(),
        (Progress total, Structure structure) => total + structure.progress);
  }

  const World.empty()
      : time = 0,
        totalProgress = const Progress(),
        structures = const <Structure>[],
        inventory = const Resources();

  World copyWith({
    int? time,
    Progress? totalProgress,
    List<Structure>? structures,
    Resources? inventory,
  }) {
    return World(
      time: time ?? this.time,
      totalProgress: totalProgress ?? this.totalProgress,
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

  @override
  String toString() {
    return 'Build ${structure.name}';
  }
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

// class ExpectedValueMap {
//   double evForAction(Action action) {
//     return 0;
//   }
// }

// class ValueActor {
//   List<Action> blockingActions(Build action, World world) {
//     // Diff needs with available resources (including energy)
//     var unmetResources = action.structure.cost - world.inventory;
//     var uniqueResources = unmetResources.sumPostive();

//     // Recurse for a buildable energy source.
//     return [];
//   }

//   @override
//   Action chooseAction(Simulation sim) {
//     var actionToEv = ExpectedValueMap();

//     // Calculate the time distance from goal at current pace.
//     double timeToGoal = sim.goal.timeToGoal(sim.world.progressPerSecond);
//     // Look through all available (not necessarily buildable) structure builds.
//     for (var action in sim.unlockedStructureActions) {
//       // Calculate the EV of a given build (time saved?)
//       var ev = computeEvFor(action, sim.world, timeToGoal);
//       var blocking = blockingActions(action);
//       // Divide ev between missing ingredients or buildable energy sources.
//       var evPer = ev / blocking.length;
//     }
//     // Setting ev(ingredient) = max(ev(structure) / # missing, ev(ingredient))
//     // Sort actions by EV.
//     // If equal, pick randomly.
//   }
// }

// Picks the best action, ignoring material costs.
class Sprinter extends Actor {
  double timeToGoalWith(Simulation sim, Build action) {
    var structures = List<Structure>.from(sim.world.structures);
    var newWorld =
        sim.world.copyWith(structures: structures..add(action.structure));
    var newProgressPerSecond = newWorld.progressPerSecond;
    return sim.goal.timeToGoal(newWorld);
    // var tiPerSecond = newProgressPerSecond.terraformationIndex -
    //     currentProgressPerSecond.terraformationIndex;
    // return tiPerSecond / action.time;
  }

  @override
  Action chooseAction(Simulation sim) {
    // Calculate the time distance from goal at current pace.
    double timeToGoal = sim.goal.timeToGoal(sim.world);
    Build? bestAction;
    double bestTimeToGoalDelta = 0;
    // Look through all available (not necessarily buildable) structure builds.
    for (var action in sim.unlockedStructureActions) {
      var newTimeToGoal = timeToGoalWith(sim, action);
      var timeToGoalDelta = newTimeToGoal - timeToGoal;
      if (timeToGoalDelta <= bestTimeToGoalDelta) {
        bestAction = action;
        bestTimeToGoalDelta = timeToGoalDelta;
      }
    }
    return bestAction!;
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

class Goal {
  final int terraformingIndexGoal;

  Goal(this.terraformingIndexGoal);

  bool wasReached(Progress totalProgress) {
    return totalProgress.terraformationIndex >= terraformingIndexGoal;
  }

  // Intentionally can return infinity.
  double timeToGoal(World world) {
    double distanceToGoal =
        terraformingIndexGoal - world.totalProgress.terraformationIndex;
    return distanceToGoal / world.progressPerSecond.terraformationIndex;
  }
}

class Simulation {
  final World world;
  final Goal goal;

  Simulation(this.world, this.goal);

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

  Iterable<Build> get unlockedStructureActions {
    // All structures are currently unlocked.
    return allStructures.map((structure) => Build(structure));
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

  var totalProgress =
      world.totalProgress + world.progressPerSecond * action.time.toDouble();

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
    totalProgress: totalProgress,
  );
}

SimulationResult simulate(World world, Actor actor, Goal goal) {
  var sim = Simulation(world, goal);
  var actionLog = <Action>[];
  var previousTime = world.time;
  var lastLogTime = world.time;
  var logFrequency = 10;

  while (!goal.wasReached(world.totalProgress)) {
    var action = actor.chooseAction(sim);
    world = applyAction(action, world);
    assert(previousTime < world.time);
    if (world.time > lastLogTime + logFrequency) {
      print("${world.time} : TI ${world.totalProgress.terraformationIndex}");
      lastLogTime = world.time;
    }
    actionLog.add(action);
  }
  return SimulationResult(world, actionLog);
}
