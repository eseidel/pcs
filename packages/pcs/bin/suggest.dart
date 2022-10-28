import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main() {
  // based on hardcoded config
  var world = World(
    time: 0, // ignored
    inventory: ItemCounts(), // ignored.
    // Want a constructor to take a Ti and divide between factors?
    totalProgress: Progress(
      pressure: Pressure.nPa(0),
      heat: Heat.nK(0),
      biomass: Biomass.g(0),
    ),
    structures: [
      Items.biodome1,
      Items.biodome2,
      for (var i = 0; i < 13; i++) Items.heater4,
      for (var i = 0; i < 15; i++) Items.drill4,
      Items.grassspreader,
      for (var i = 0; i < 3; i++) Items.flowerspreader1,
      for (var i = 0; i < 3; i++) Items.flowerspreader2,
      Items.algaegenerator1,
      for (var i = 0; i < 6; i++) Items.algaegenerator2,
      for (var i = 0; i < 4; i++) Items.treespreader1,
      for (var i = 0; i < 3; i++) Items.treespreader2,
      for (var i = 0; i < 5; i++) Items.treespreader3,
      for (var i = 0; i < 5; i++) Items.oreextractor2,
      Items.gasextractor,
      for (var i = 0; i < 10; i++) Items.rocketoxygen, // 02
      for (var i = 0; i < 12; i++) Items.rocketheat, // heat
      for (var i = 0; i < 5; i++) Items.rocketpressure, // pressure
      for (var i = 0; i < 22; i++) Items.rocketplants, // biomass (plants)
    ],
  );

  // print base production and total production
  var base =
      world.calculateProgressPerSecond(ignoreEnergy: true, ignoreRockets: true);
  var total = world.calculateProgressPerSecond(ignoreEnergy: true);
  print("Base: $base");
  print("Total: $total");

  // suggest next best building to make from available buildings.
}
