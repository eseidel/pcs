import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

import 'package:test/test.dart';

void main() {
  test('canBuild', () {
    var structure = strutureWithName("Wind Turbine");
    expect(canAfford(structure, 0, ItemCounts.fromItems([Items.iron])), isTrue);
  });

  test('applyAction', () {
    var afterGather =
        applyAction(Gather(items: [Items.iron], time: 1), World.empty());

    expect(afterGather.time, 1);
    expect(afterGather.inventory.countOf(Items.iron), 1);

    var turbine = strutureWithName("Wind Turbine");
    var afterBuild = applyAction(Build(turbine), afterGather);

    expect(afterBuild.time, 2);
    expect(afterBuild.structures.first, turbine);
    expect(afterBuild.availableEnergy, turbine.energy);
    expect(afterBuild.inventory.countOf(Items.iron), 0);
  });

  test('Plan.executionTime', () {
    var turbine = strutureWithName("Wind Turbine");
    var buildTurbine = Build(turbine);
    var plan = Plan([buildTurbine, buildTurbine]);
    expect(buildTurbine.time, greaterThan(0));
    expect(plan.totalActionTime, buildTurbine.time * 2);
  });
}
