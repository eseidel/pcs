import 'package:pcs/pcs.dart';
import 'package:test/test.dart';

Structure strutureWithName(String name) {
  for (var structure in allStructures) {
    if (structure.name == name) {
      return structure;
    }
  }
  throw ArgumentError.value(name, "No structure with name");
}

void main() {
  test('canBuild', () {
    var structure = strutureWithName("Wind Turbine");
    expect(canAfford(structure, 0, Resources(iron: 1)), isTrue);
  });

  test('applyAction', () {
    var afterGather = applyAction(
        Gather(resource: Resources(iron: 1), time: 1), World.empty());

    expect(afterGather.time, 1);
    expect(afterGather.inventory.iron, 1);

    var turbine = strutureWithName("Wind Turbine");
    var afterBuild = applyAction(Build(turbine), afterGather);

    expect(afterBuild.time, 2);
    expect(afterBuild.structures.first, turbine);
    expect(afterBuild.availableEnergy, turbine.energy);
    expect(afterBuild.inventory.iron, 0);
  });
}
