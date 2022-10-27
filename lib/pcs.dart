import 'structures.dart';

class Unlocks {
  final Progress progress;

  Unlocks.forProgress(this.progress);

  Iterable<Structure> get unlockedStructures {
    // Cache this?
    return allStructures.where((structure) => structure.isAvailable(progress));
  }

  Iterable<Structure> get unlockedEnergyStructures {
    return unlockedStructures.where((structure) => structure.energy > 0);
  }

  Iterable<Structure> get unlockedNonEnergyStructures {
    return unlockedStructures.where((structure) => structure.energy < 0);
  }
}

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
    if (goal.ti != null) {
      double distanceToGoal = goal.ti!.value - totalProgress.ti.value;
      return distanceToGoal / progressPerSecond.ti.value;
    } else if (goal.heat != null) {
      double distanceToGoal = goal.heat!.pK - totalProgress.heat.pK;
      return distanceToGoal / progressPerSecond.heat.pK;
    } else if (goal.oxygen != null) {
      double distanceToGoal = goal.oxygen!.ppq - totalProgress.oxygen.ppq;
      return distanceToGoal / progressPerSecond.oxygen.ppq;
    } else if (goal.pressure != null) {
      double distanceToGoal = goal.pressure!.nPa - totalProgress.pressure.nPa;
      return distanceToGoal / progressPerSecond.pressure.nPa;
    }
    double distanceToGoal = goal.biomass!.grams - totalProgress.biomass.grams;
    return distanceToGoal / progressPerSecond.biomass.grams;
  }

  Unlocks get unlocks => Unlocks.forProgress(totalProgress);
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
  final List<Item> items;

  Gather({required this.items, required double time})
      : super(time: time, name: items.map((item) => item.name).join(', '));
}

class Build extends Action {
  final Structure structure;
  Build(this.structure) : super(time: 1, name: structure.name);
}

abstract class Actor {
  Action chooseAction(PlanContext context);
}

// Need a way to evaluate value in terms of destructions.
// e.g. that a 1 resource is worth N seconds (gather time?)
// Or that 1 energy is worth N seconds
//
// Are higher-level energy sources ever cheaper per second than wind power?

// Once we build a plan for a structure, don't we just execute it?
// Do we re-plan any time we reach an intermediate goal/unlock?

// This is slightly confused because we use this both for generating
// the plan as well as execution thereof.  During planning
// we should use things like TimeCostEstimates and only
// have one non-energy structure in a given plan.
// But during execution, we don't really care whats in a plan.
class Plan {
  final List<Action> actions;

  Plan(this.actions);

  double get totalActionTime =>
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

// Prices are expressed in time per unit.
// Prices are computed based on averges, and may not exactly match
// prices at execution time.  e.g. if we already have available energy
// or resources in inventory those maybe "free", or travel time overhead
// (to a different regon) may be averaged out across multiple resources
// depending on boot speed or inventory size.
// Should keep cost estimates for structures too?
class TimeCostEstimates {
  // Should this be some sort of "unlocks state"?
  final Unlocks unlocks;
  late double timeCostForEnergy;

  TimeCostEstimates(this.unlocks) {
    var plan = bestAvailableEnergyPlan(this);
    timeCostForEnergy = plan.totalActionTime / plan.energyDelta;
  }

  double timeCostForItem(Item item) {
    // These could have time relative to position?
    // Supposedly resources do not respawn?  If so the more each is
    // gathered, the longer it should take to get?
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

  // This is written to allow different rate structures for different
  // neededEnergy sizes.  Currently only used as neededEnergy = 1;
  static Iterable<Plan> possibleEnergyStructurePlans(
      TimeCostEstimates timeCostEstimates,
      {double neededEnergy = 1}) {
    assert(neededEnergy > 0);

    return timeCostEstimates.unlocks.unlockedEnergyStructures
        .map((energyStructure) {
      var builder = PlanBuilder(
          timeCosts: timeCostEstimates, availableEnergy: -neededEnergy);
      while (builder.availableEnergy < 0) {
        builder.planForStructure(energyStructure);
      }
      return builder.build();
    });
  }

  // Inputs: TimeCosts + unlockedStructures?

  // Negative energyDelta's require more, positive don't.
  static Plan bestAvailableEnergyPlan(TimeCostEstimates costEstimates,
      {double neededEnergy = 1}) {
    // Generate plans for all available energy structures.
    // Pick the plan with the highest energy per time spent ratio.

    var possiblePlans =
        possibleEnergyStructurePlans(costEstimates, neededEnergy: neededEnergy);

    Plan? bestEnergyPlan;
    double bestEnergyPerExecutionSeconds = 0;
    for (var plan in possiblePlans) {
      var energyPerExecutionSeconds = plan.energyDelta / plan.totalActionTime;
      if (energyPerExecutionSeconds > bestEnergyPerExecutionSeconds) {
        bestEnergyPlan = plan;
        bestEnergyPerExecutionSeconds = energyPerExecutionSeconds;
      }
    }
    if (bestEnergyPlan == null) {
      throw StateError("No best energy plan found");
    }
    return bestEnergyPlan;
  }

  double timeCostForStructure(Structure structure) {
    var timeCost = 0.0;
    if (structure.energy < 0) {
      timeCost += timeCostForEnergy * structure.energy.abs();
    }
    for (var item in structure.cost) {
      timeCost + timeCostForItem(item);
    }
    return timeCost;
  }
}

// Plan builder is used both at planning time and execution time.
// At planning time it operates only from TimeCostEstimates
// were as at execution time, it needs to take into account
// available resources?
// During TimeCostEstimates PlanBuilder is simply called with a controlled
// environment to simulate nothing being available, where as during
// execution time PlanBuilder is called with real availabilities.
class PlanBuilder {
  // FIXME: This should only be for planning, not for execution?

  final TimeCostEstimates timeCosts;
  final List<Action> _actions;
  double availableEnergy;

  PlanBuilder({required this.timeCosts, required this.availableEnergy})
      : _actions = [];

  void addSubPlan(Plan plan) {
    for (var action in plan.actions) {
      if (action is Build) {
        _buildStructure(action.structure);
      } else if (action is Gather) {
        _fetchItems(action.items);
      } else {
        throw ArgumentError("Unknown Action type?");
      }
    }
  }

  void planForEnergy(double neededEnergy) {
    var plan = TimeCostEstimates.bestAvailableEnergyPlan(timeCosts,
        neededEnergy: neededEnergy);
    addSubPlan(plan);
  }

  void planForStructure(Structure structure) {
    if (structure.energy < 0 && availableEnergy < structure.energy.abs()) {
      // structure energy is negative
      var neededEnergy = availableEnergy + structure.energy;
      assert(neededEnergy < 0);
      planForEnergy(neededEnergy.abs());
    }
    planForResources(structure.cost);
    _buildStructure(structure);
  }

  void _buildStructure(Structure structure) {
    availableEnergy += structure.energy;
    _actions.add(Build(structure));
  }

  void planForResources(List<Item> items) {
    _fetchItems(items);
  }

  void _fetchItems(List<Item> items) {
    var time = items.fold(0.0,
        (double total, Item item) => total + timeCosts.timeCostForItem(item));
    _actions.add(Gather(items: items, time: time));
  }

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

class Sprinter extends Actor {
  PlanIterator? existingPlan;

  double timeToGoalWithPlan(PlanContext sim, Plan plan) {
    var newStructures = List<Structure>.from(sim.world.structures);
    for (var action in plan.actions) {
      if (action is Build) {
        newStructures.add(action.structure);
      }
    }
    // FIXME: Share code with applyAction?
    var timeDelta = plan.totalActionTime;
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
  Plan findBestPlan(PlanContext sim) {
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
      var executionTime = plan.totalActionTime;
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
  Action chooseAction(PlanContext context) {
    if (existingPlan != null && existingPlan!.moveNextAction()) {
      return existingPlan!.currentAction;
    } else {
      existingPlan = null;
    }

    var bestPlan = findBestPlan(context);
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

class PlanContext {
  final World world;
  final Goal goal;

  PlanContext(this.world, this.goal);

  Iterable<Plan> get possibleNonEnergyStructurePlans sync* {
    // Gather plans only make sense as sub-plans.
    // Energy plans only make sense as sub-plans.
    // Chips and inventory make sense as sub-plans.
    // Structures (and rockets) are the only top-level plans
    // (i.e. plans that move towards a goal).
    for (var structure in world.unlocks.unlockedNonEnergyStructures) {
      var timeCosts = TimeCostEstimates(world.unlocks);
      var builder = PlanBuilder(
          timeCosts: timeCosts, availableEnergy: world.availableEnergy);
      builder.planForStructure(structure);
      yield builder.build();
    }
  }
}

World applyAction(Action action, World world) {
  var totalProgress =
      world.totalProgress + world.progressPerSecond * action.time.toDouble();
  var time = world.time + action.time;
  var inventory = world.inventory;
  var structures = world.structures;

  if (action is Gather) {
    inventory += ItemCounts.fromItems(action.items);
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
  var action = actor.chooseAction(PlanContext(world, goal));
  return ActionResult(action, applyAction(action, world));
}
