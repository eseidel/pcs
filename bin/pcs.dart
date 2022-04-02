import 'package:pcs/pcs.dart';

void main(List<String> arguments) {
  print("hello");

  var result = simulate(World.empty(), PreferBuild(),
      (world) => world.progress.terraformationIndex > 100);
  print(
      "Reached goal in ${result.world.time} with ${result.actionLog.length} actions");
}
