import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main() {
  var world = World(
    inventory: ItemCounts(),
    time: 0,
    totalProgress: Progress.allUnlocks(),
    structures: [],
  );
  var sim = Simulation(world, Goal.zero());
  var plans = sim.possibleNonEnergyStructurePlans.toList();

  // For each possible plan, print the the Ti/(s*s)?
  double progressPerActionSecond(Plan plan) =>
      plan.tiDelta.value / plan.executionTime;

  // plans.sort((a, b) =>
  //     -progressPerActionSecond(a).compareTo(progressPerActionSecond(b)));

  plans.sort((a, b) {
    var aStructure = (a.actions.last as Build).structure;
    var bStructure = (b.actions.last as Build).structure;
    return aStructure.unlocksAt
        .toTi()
        .value
        .compareTo(bStructure.unlocksAt.toTi().value);
  });

  for (var plan in plans) {
    var structure = (plan.actions.last as Build).structure;
    print(
        "${structure.name} time: ${plan.executionTime} tiDelta: ${plan.tiDelta} tiDelta/time: ${progressPerActionSecond(plan).toStringAsFixed(4)} unlocksAt: ${structure.unlocksAt}");
  }

  // Questions to answer
  // List of structures ordered by ti unlock and tiDelta?
  // List of structures ordered by unlock / areaDelta?

  // For Planning:
  // Figure out all subgoals/unlocks along the way to the Goal.
  // Evaluate from any of the unlocks, if available from time of unlock
  // would they accelerate time to goal.
  // Is it then just a path-planning problem?  Plan from 0 -> subgoal -> subgoal -> goal, etc?

  // var stage = stageByName("Blue Sky");
  // print("For ${stage.name}");

  // sim = Simulation(World.empty(), Goal.zero());
  // var possibleSubGoals = sim.unlockableStructuresBeforeGoal(stage.startsAt);
}
