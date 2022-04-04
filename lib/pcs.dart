import "dart:math";

enum Item {
  iron,
  iridium,
  ice,
  aluminium,
  cobalt,
  magnesium,
  silicon,
  superAlloy,
  titanium,
  plant,
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
  final List<Item> cost;
  final double energy;
  final Progress progress;
  final String name;
  final String description;

  bool isAvailable(World world) {
    return true;
  }

  const Structure({
    required this.availablility,
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
    availablility: Availablility.always(),
    cost: [Item.titanium, Item.iron],
    energy: -0.5,
    progress: Progress(pressure: 0.2),
  ),
  Structure(
    name: "Wind Turbine",
    availablility: Availablility.always(),
    cost: [Item.iron],
    energy: 1.2,
  ),
  Structure(
    name: "Heater T1",
    availablility: Availablility.always(),
    cost: [Item.iron, Item.iridium, Item.silicon],
    progress: Progress(heat: 0.3),
    energy: -1,
  ),
  Structure(
    name: "Vegetube T1",
    availablility: Availablility.always(),
    cost: [Item.iron, Item.ice, Item.magnesium, Item.plant],
    progress: Progress(oxygen: 1.5),
    energy: -.35,
  ),
];

Structure strutureWithName(String name) {
  for (var structure in allStructures) {
    if (structure.name == name) {
      return structure;
    }
  }
  throw ArgumentError.value(name, "No structure with name");
}

class World {
  final int time;
  final Progress totalProgress;

  final List<Structure> structures;
  final ItemCounts inventory;

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

  // FIXME: Make this const
  World.empty()
      : time = 0,
        totalProgress = const Progress(),
        structures = const <Structure>[],
        inventory = ItemCounts();

  World copyWith({
    int? time,
    Progress? totalProgress,
    List<Structure>? structures,
    ItemCounts? inventory,
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
  final Item resource;

  const Gather({required this.resource, required int time}) : super(time: time);

  @override
  String toString() {
    return 'Gather ${resource.name} (${time}s)';
  }
}

class Build extends Action {
  final Structure structure;
  Build(this.structure) : super(time: 1);

  @override
  String toString() {
    return 'Build ${structure.name} (${time}s)';
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

// Need a way to evaluate value in terms of destructions.
// e.g. that a 1 resource is worth N seconds (gather time?)
// Or that 1 energy is worth N seconds
//
// Are higher-level energy sources ever cheaper per second than wind power?

// Once we build a plan for a structure, don't we just execute it?
// Do we re-plan any time we reach an intermediate goal/unlock?

class Plan {
  final List<Action> actions;

  Plan(this.actions);

  int get executionTime => actions.fold(0, (total, action) => action.time);

  // Total Resource change?
}

// Ignore inventory planning for now?
// Ignore energy surplus planning for now?
// Build up subplans of all the various things
// Then replay the subplans with inventory / energy available
class PlanBuilder {
  List<Action> actions;
  Simulation sim;

  PlanBuilder(this.sim) : actions = [];

  void planForEnergy(double neededEnergy) {
    // FIXME: Don't lookup every time.
    final energyStructures = <Structure>[strutureWithName("Wind Turbine")];
    while (neededEnergy > 0) {
      var structure = energyStructures.first;
      planForStructure(structure);
      neededEnergy -= structure.energy;
    }
  }

  void planForStructure(Structure structure) {
    var worldEnergy = 0; // FIXME: ignoring existing energy.
    for (var item in structure.cost) {
      planForResource(item);
    }
    if (structure.energy < 0 && worldEnergy < structure.energy.abs()) {
      // structure energy is negative
      var neededEnergy = worldEnergy + structure.energy;
      assert(neededEnergy < 0);
      planForEnergy(neededEnergy);
    }
    actions.add(Build(structure));
  }

  void planForResource(Item item) {
    actions.add(Gather(resource: item, time: sim.gatherTimeFor(item)));
  }

  Plan build() {
    return Plan(actions);
  }
}

class PlanIterator {
  Plan plan;
  int currentActionIndex;

  PlanIterator(this.plan) : currentActionIndex = -1;

  bool moveNextAction() {
    currentActionIndex += 1;
    return currentActionIndex < plan.actions.length;
  }

  Action get currentAction => plan.actions[currentActionIndex];
}

// Picks the best action, ignoring material costs.
class Sprinter extends Actor {
  PlanIterator? existingPlan;

  double timeToGoalWithPlan(Simulation sim, Plan plan) {
    var newStructures = List<Structure>.from(sim.world.structures);
    for (var action in plan.actions) {
      if (action is Build) {
        newStructures.add(action.structure);
      }
    }
    var newWorld = sim.world.copyWith(structures: newStructures);
    // var newProgressPerSecond = newWorld.progressPerSecond;
    return plan.executionTime + sim.goal.timeToGoal(newWorld);
    // var tiPerSecond = newProgressPerSecond.terraformationIndex -
    //     currentProgressPerSecond.terraformationIndex;
    // return tiPerSecond / action.time;
  }

  @override
  Action chooseAction(Simulation sim) {
    if (existingPlan != null && existingPlan!.moveNextAction()) {
      return existingPlan!.currentAction;
    } else {
      existingPlan = null;
    }

    // Calculate the time distance from goal at current pace.
    double timeToGoal = sim.goal.timeToGoal(sim.world);
    Plan? bestPlan;
    double bestTimeToGoalDelta = 0;
    // Generate plans for all available structures.
    // Pick the plan with the highest EV.
    for (var plan in sim.possiblePlans) {
      var newTimeToGoal = timeToGoalWithPlan(sim, plan);
      var timeToGoalDelta = newTimeToGoal - timeToGoal;
      if (timeToGoalDelta <= bestTimeToGoalDelta) {
        bestPlan = plan;
        bestTimeToGoalDelta = timeToGoalDelta;
      }
    }
    if (bestPlan == null) {
      throw StateError("No best plan found");
    }

    existingPlan = PlanIterator(bestPlan);
    existingPlan!.moveNextAction();
    return existingPlan!.currentAction;
  }
}

class SimulationResult {
  final World world;
  final List<Action> actionLog;

  SimulationResult(this.world, this.actionLog);
}

bool canAfford(Structure structure, double worldEnergy, ItemCounts inventory) {
  if (structure.energy < 0 && worldEnergy < structure.energy.abs()) {
    return false;
  }
  return ItemCounts.fromItems(structure.cost) <= inventory;
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

  // FIXME: not all items can be gathered?
  // These could have time relative to position?
  int gatherTimeFor(Item item) {
    const int nearby = 5;
    const int distant = 60;
    switch (item) {
      case Item.aluminium:
        return distant;
      case Item.cobalt:
        return nearby;
      case Item.ice:
        return nearby;
      case Item.iridium:
        return distant;
      case Item.iron:
        return nearby;
      case Item.magnesium:
        return nearby;
      case Item.plant:
        return distant;
      case Item.silicon:
        return nearby;
      case Item.superAlloy:
        return distant;
      case Item.titanium:
        return nearby;
    }
  }

  Iterable<Gather> get gatherActions {
    return Item.values.map((i) => Gather(resource: i, time: gatherTimeFor(i)));
  }

  Iterable<Structure> get unlockedStructures {
    // All structures are currently unlocked.
    return allStructures;
  }

  Iterable<Build> get unlockedStructureActions {
    return unlockedStructures.map((structure) => Build(structure));
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

  Plan planForStructure(Structure structure) {
    var builder = PlanBuilder(this);
    builder.planForStructure(structure);
    return builder.build();
  }

  Iterable<Plan> get possiblePlans sync* {
    // Gather plans only make sense as sub-plans.
    // Energy plans only make sense as sub-plans.
    // Chips and inventory make sense as sub-plans.
    // Structures (and rockets) are the only top-level plans
    // (i.e. plans that move towards a goal).
    for (var structure in unlockedStructures) {
      yield planForStructure(structure);
    }
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
    inventory.adjust(action.resource, 1);
  } else if (action is Build) {
    inventory -= ItemCounts.fromItems(action.structure.cost);
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
