import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main() {
  var world = World(
    inventory: ItemCounts(),
    time: 0,
    totalProgress: Progress.allUnlocks(),
    structures: [],
  );
  var costEstimates = TimeCostEstimates(world.unlocks);
  var plans = TimeCostEstimates.possibleEnergyStructurePlans(costEstimates,
          neededEnergy: 1)
      .toList();

  double energyPerActionSecond(Plan plan) =>
      plan.energyDelta / plan.totalActionTime;

  plans.sort(
      (a, b) => -energyPerActionSecond(a).compareTo(energyPerActionSecond(b)));

  for (var plan in plans) {
    print(
        "${plan.actions.last.name} time: ${plan.totalActionTime} energy: ${plan.energyDelta} ratio: ${energyPerActionSecond(plan).toStringAsFixed(2)}");
  }
}
