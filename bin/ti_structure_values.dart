import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

// Possibly belongs as Plan.structure?
Structure structureFor(Plan plan) {
  return (plan.actions.last as Build).structure;
}

// Not perfect, but good enough for sorting.
extension CompareGoal on Goal {
  int compareTo(Goal other) {
    return toTi().value.compareTo(other.toTi().value);
  }
}

void main() {
  var world = World(
    inventory: ItemCounts(),
    time: 0,
    totalProgress: Progress.allUnlocks(),
    structures: [],
  );
  var sim = PlanContext(world, Goal.zero());
  var plans = sim.possibleNonEnergyStructurePlans.toList();

  // For each possible plan, print the the Ti/(s*s)?
  double progressPerActionSecond(Plan plan) =>
      plan.tiDelta.value / plan.executionTime;

  plans.sort((a, b) =>
      -progressPerActionSecond(a).compareTo(progressPerActionSecond(b)));

  // plans.sort((a, b) {
  //   return structureFor(a).unlocksAt
  //       .compareTo(structureFor(b).unlocksAt);
  // });

  for (var plan in plans) {
    var structure = (plan.actions.last as Build).structure;
    var buffer = StringBuffer();
    // Done one per line for easy commenting out/reordering.
    buffer.write(structure.name);
    buffer.write(" time: ${plan.executionTime}");
    buffer.write(" tiDelta: ${plan.tiDelta}");
    buffer.write(
        " tiDelta/time: ${progressPerActionSecond(plan).toStringAsFixed(4)}");
    buffer.write(" unlocksAt: ${structure.unlocksAt}");
    print(buffer.toString());
  }

  // Questions to answer
  // List of structures ordered by ti unlock and tiDelta?
  // List of structures ordered by unlock / areaDelta?

  // For Planning:
  // Figure out all subgoals/unlocks along the way to the Goal.
  // Evaluate from any of the unlocks, if available from time of unlock
  // would they accelerate time to goal.
  // Is it then just a path-planning problem?  Plan from 0 -> subgoal -> subgoal -> goal, etc?
}
