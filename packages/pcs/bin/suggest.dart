import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

World worldAddingStructure(World world, Structure structure) {
  final newWorld = world.copyWith(
    structures: [...world.structures, structure],
  );
  return newWorld;
}

class Change {
  final Structure structure;
  final World oldWorld;
  final World newWorld;
  final Progress progressPerSecondDelta;
  const Change({
    required this.oldWorld,
    required this.newWorld,
    required this.structure,
    required this.progressPerSecondDelta,
  });
}

List<Change> possibleChanges(World world) {
  final changes = <Change>[];
  // FIXME: This should be unlocked buildable structures instead.
  for (var item in Items.all) {
    if (item.progress.isZero && item.type != ItemType.rocket) {
      continue;
    }
    final newWorld = worldAddingStructure(world, item);
    final progressPerSecondDelta =
        newWorld.calculateProgressPerSecond(ignoreEnergy: true) -
            world.calculateProgressPerSecond(ignoreEnergy: true);
    final change = Change(
      oldWorld: world,
      newWorld: newWorld,
      structure: item,
      progressPerSecondDelta: progressPerSecondDelta,
    );
    changes.add(change);
  }
  return changes;
}

List<Item> listFromMapCounts(Map<Item, int> map) {
  final list = <Item>[];
  for (var entry in map.entries) {
    for (var i = 0; i < entry.value; i++) {
      list.add(entry.key);
    }
  }
  return list;
}

void main() {
  // based on hardcoded config
  var world = World.empty().copyWith(
    structures: listFromMapCounts({
      Items.biodome1: 1,
      Items.biodome2: 1,
      Items.heater4: 13,
      Items.drill4: 15,
      Items.grassspreader: 1,
      Items.flowerspreader1: 3,
      Items.flowerspreader2: 3,
      Items.algaegenerator1: 1,
      Items.algaegenerator2: 6,
      Items.treespreader1: 4,
      Items.treespreader2: 3,
      Items.treespreader3: 5,
      Items.oreextractor2: 5,
      Items.gasextractor: 1,
      Items.rocketoxygen: 10,
      Items.rocketheat: 12,
      Items.rocketpressure: 5,
      Items.rocketplants: 22,
    }),
  );

  // print base production and total production
  var base =
      world.calculateProgressPerSecond(ignoreEnergy: true, ignoreRockets: true);
  var total = world.calculateProgressPerSecond(ignoreEnergy: true);
  print("Base: $base");
  print("Total: $total");

  // suggest next best building to make from available buildings.
  var changes = possibleChanges(world);
  changes.sort((a, b) => b.progressPerSecondDelta.ti.value
      .compareTo(a.progressPerSecondDelta.ti.value)); // descending

  for (var change in changes) {
    print("${change.structure.name} ${change.progressPerSecondDelta}");
  }

  // Suggest the top 2 for each category?
  // Walk through all available structures and suggest one to build?
}
