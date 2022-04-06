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

  plans.sort((a, b) =>
      -progressPerActionSecond(a).compareTo(progressPerActionSecond(b)));

  for (var plan in plans) {
    print(
        "${plan.actions.last.name} time: ${plan.executionTime} tiDelta: ${plan.tiDelta} tiDelta/time: ${progressPerActionSecond(plan).toStringAsFixed(4)}");
  }
}
