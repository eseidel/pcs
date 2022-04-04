import 'package:pcs/pcs.dart';
import 'package:test/test.dart';

void main() {
  test('canBuild', () {
    var structure = strutureWithName("Wind Turbine");
    expect(canAfford(structure, 0, ItemCounts.fromItems([Item.iron])), isTrue);
  });

  test('applyAction', () {
    var afterGather =
        applyAction(Gather(resource: Item.iron, time: 1), World.empty());

    expect(afterGather.time, 1);
    expect(afterGather.inventory.countOf(Item.iron), 1);

    var turbine = strutureWithName("Wind Turbine");
    var afterBuild = applyAction(Build(turbine), afterGather);

    expect(afterBuild.time, 2);
    expect(afterBuild.structures.first, turbine);
    expect(afterBuild.availableEnergy, turbine.energy);
    expect(afterBuild.inventory.countOf(Item.iron), 0);
  });
}
