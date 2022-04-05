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
  var builder = PlanBuilder(sim);
  var plans = builder.possibleEnergyStructurePlans(1);
  for (var plan in plans) {
    var energyPerActionSecond = plan.energyDelta / plan.executionTime;
    print(
        "${plan.actions.last.name} time: ${plan.executionTime} energy: ${plan.energyDelta} ratio: ${energyPerActionSecond.toStringAsFixed(2)}");
  }
}
