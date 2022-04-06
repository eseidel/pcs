import 'structures.dart';

class World {
  final double time;
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
    if (availableEnergy < 0) {
      return Progress();
    }
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
    double? time,
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

  // Intentionally can return infinity.
  double timeToGoal(Goal goal) {
    double distanceToGoal = goal.ti!.value - totalProgress.ti.value;
    return distanceToGoal / progressPerSecond.ti.value;
  }
}

class Action {
  final double time;
  final String name;

  const Action({required this.time, required this.name});

  @override
  String toString() {
    return '$runtimeType $name (${time.toStringAsFixed(0)}s)';
  }
}

class Gather extends Action {
  final Item resource;

  Gather({required this.resource, required double time})
      : super(time: time, name: resource.name);
}

class Build extends Action {
  final Structure structure;
  Build(this.structure) : super(time: 1, name: structure.name);
}

abstract class Actor {
  Action chooseAction(Simulation sim);
}

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

  double get executionTime =>
      actions.fold(0, (total, action) => total + action.time);

  double get energyDelta => actions.fold(
      0,
      (total, action) =>
          total + (action is Build ? action.structure.energy : 0));

  Ti get tiDelta => actions.fold(
      Ti(0),
      (total, action) =>
          total + (action is Build ? action.structure.progress.ti : Ti(0)));

  // Total Resource change?
}

// Ignore inventory planning for now?
// Build up and cache subplans and then replay with energy/item availability?
class PlanBuilder {
  final List<Action> _actions;
  final Simulation sim;
  // Should this just a be `World future`?
  // Or computed from _actions based on sim.world.availableEnergy?
  double availableEnergy;

  PlanBuilder(this.sim)
      : _actions = [],
        availableEnergy = sim.world.availableEnergy;

  void addSubPlan(Plan plan) {
    for (var action in plan.actions) {
      if (action is Build) {
        _buildStructure(action.structure);
      } else if (action is Gather) {
        _fetchItem(action.resource);
      } else {
        throw ArgumentError("Unknown Action type?");
      }
    }
  }

  Iterable<Plan> possibleEnergyStructurePlans(double neededEnergy) {
    assert(neededEnergy > 0);
    return sim.unlockedEnergyStructures.map((energyStructure) {
      var builder = PlanBuilder(sim);
      builder.availableEnergy = -neededEnergy;
      while (builder.availableEnergy < 0) {
        builder.planForStructure(energyStructure);
      }
      return builder.build();
    });
  }

  // Negative energyDelta's require more, positive don't.
  void planForEnergy(double neededEnergy) {
    // Generate plans for all available energy structures.
    // Pick the plan with the highest energy per time spent ratio.

    // FIXME: Don't recompute every time?
    var possiblePlans = possibleEnergyStructurePlans(neededEnergy);

    Plan? bestEnergyPlan;
    double bestEnergyPerExecutionSeconds = 0;
    for (var plan in possiblePlans) {
      var energyPerExecutionSeconds = plan.energyDelta / plan.executionTime;
      if (energyPerExecutionSeconds > bestEnergyPerExecutionSeconds) {
        bestEnergyPlan = plan;
        bestEnergyPerExecutionSeconds = energyPerExecutionSeconds;
      }
    }
    if (bestEnergyPlan == null) {
      throw StateError("No best energy plan found");
    }
    addSubPlan(bestEnergyPlan);
  }

  void _buildStructure(Structure structure) {
    availableEnergy += structure.energy;
    _actions.add(Build(structure));
  }

  void planForStructure(Structure structure) {
    if (structure.energy < 0 && availableEnergy < structure.energy.abs()) {
      // structure energy is negative
      var neededEnergy = availableEnergy + structure.energy;
      assert(neededEnergy < 0);
      planForEnergy(neededEnergy.abs());
    }
    for (var item in structure.cost) {
      planForResource(item);
    }
    _buildStructure(structure);
  }

  void _fetchItem(Item item) =>
      _actions.add(Gather(resource: item, time: sim.gatherTimeFor(item)));

  void planForResource(Item item) => _fetchItem(item);

  Plan build() {
    return Plan(_actions);
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
    // FIXME: Share code with applyAction?
    var timeDelta = plan.executionTime;
    var futureTime = sim.world.time + timeDelta;
    var futureProgress = sim.world.totalProgress +
        sim.world.progressPerSecond * timeDelta.toDouble();
    var newWorld = sim.world.copyWith(
        structures: newStructures,
        totalProgress: futureProgress,
        time: futureTime);
    // var newProgressPerSecond = newWorld.progressPerSecond;
    return newWorld.timeToGoal(sim.goal);
    // var tiPerSecond = newProgressPerSecond.terraformationIndex -
    //     currentProgressPerSecond.terraformationIndex;
    // return tiPerSecond / action.time;
  }

  // The best plan is the one which reduces our time to goal
  // by the most, per second spent executing the plan.
  Plan findBestPlan(Simulation sim) {
    // Calculate the time distance from goal at current pace.
    double timeToGoal = sim.world.timeToGoal(sim.goal);
    // FIXME: When timeToGoal is infinity the logic below breaks.
    // We should probably just pick the fastest to complete (not best
    // improvement) to get away from infinity as soon as possible?
    if (timeToGoal.isInfinite) {
      timeToGoal = double.maxFinite;
    }

    Plan? bestPlan;
    double bestTimeToGoalDeltaPerSecond = 0;
    // Generate plans for all available structures.
    // Pick the plan with the highest EV.
    for (var plan in sim.possibleNonEnergyStructurePlans) {
      var newTimeToGoal = timeToGoalWithPlan(sim, plan);
      var executionTime = plan.executionTime;
      var timeToGoalDeltaPerSecond =
          (newTimeToGoal - timeToGoal) / executionTime;
      if (timeToGoalDeltaPerSecond <= bestTimeToGoalDeltaPerSecond) {
        bestPlan = plan;
        bestTimeToGoalDeltaPerSecond = timeToGoalDeltaPerSecond;
      }
    }
    if (bestPlan == null) {
      throw StateError("No best plan found");
    }
    return bestPlan;
  }

  @override
  Action chooseAction(Simulation sim) {
    if (existingPlan != null && existingPlan!.moveNextAction()) {
      return existingPlan!.currentAction;
    } else {
      existingPlan = null;
    }

    var bestPlan = findBestPlan(sim);
    // var structure = strutureWithName("Drill T1");
    // var bestPlan = sim.planForStructure(structure);
    existingPlan = PlanIterator(bestPlan);
    existingPlan!.moveNextAction();
    return existingPlan!.currentAction;
  }
}

bool canAfford(Structure structure, double worldEnergy, ItemCounts inventory) {
  if (structure.energy < 0 && worldEnergy < structure.energy.abs()) {
    return false;
  }
  return ItemCounts.fromItems(structure.cost) <= inventory;
}

// How is this diferent from PlanBuilder?
class Simulation {
  final World world;
  final Goal goal;

  Simulation(this.world, this.goal);

  // FIXME: not all items can be gathered?
  // These could have time relative to position?
  // Supposedly resources do not respawn?  If so the more each is
  // gathered, the longer it should take to get?
  double gatherTimeFor(Item item) {
    const double nearby = 5;
    const double medium = 60;
    const double distant = 360;
    // This is a hack around currently assuming all "items" are gathered.
    const double impossible = double.infinity;
    switch (item) {
      case Item.aluminium:
        return medium;
      case Item.cobalt:
        return nearby;
      case Item.water:
      case Item.ice:
        return nearby;
      case Item.iridium:
        return medium;
      case Item.iron:
        return nearby;
      case Item.magnesium:
        return nearby;
      case Item.seedLirma:
      case Item.plant:
        return distant;
      case Item.silicon:
        return nearby;
      case Item.superAlloy:
        return distant;
      case Item.titanium:
        return nearby;
      case Item.osmium:
        return distant; // Gated until later?
      case Item.zeolite:
        return impossible; // Nearby once late?
      case Item.uranium:
      case Item.uraniumRod:
      case Item.iridumRod:
      case Item.pulsarQuartz:
      case Item.eggplant:
      case Item.fertilizer:
      case Item.fertilizerT2:
      case Item.bacteriaSample:
      case Item.treeBark:
      case Item.bioplasticNugget:
      case Item.explosivePowder:
        return impossible;
    }
  }

  Iterable<Structure> get unlockedStructures {
    // Cache this?
    return allStructures
        .where((structure) => structure.isAvailable(world.totalProgress));
  }

  Iterable<Structure> get unlockedEnergyStructures {
    return unlockedStructures.where((structure) => structure.energy > 0);
  }

  Iterable<Structure> get unlockedNonEnergyStructures {
    return unlockedStructures.where((structure) => structure.energy < 0);
  }

  Plan planForStructure(Structure structure) {
    var builder = PlanBuilder(this);
    builder.planForStructure(structure);
    return builder.build();
  }

  Iterable<Plan> get possibleNonEnergyStructurePlans sync* {
    // Gather plans only make sense as sub-plans.
    // Energy plans only make sense as sub-plans.
    // Chips and inventory make sense as sub-plans.
    // Structures (and rockets) are the only top-level plans
    // (i.e. plans that move towards a goal).
    for (var structure in unlockedNonEnergyStructures) {
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

class ActionResult {
  final Action action;
  final World world;
  const ActionResult(this.action, this.world);
}

ActionResult planOneAction(World world, Actor actor, Goal goal) {
  var action = actor.chooseAction(Simulation(world, goal));
  return ActionResult(action, applyAction(action, world));
}
