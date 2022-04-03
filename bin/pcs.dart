import 'package:pcs/pcs.dart';

void main(List<String> arguments) {
  print("hello");

  var result = simulate(World.empty(), Sprinter(), Goal(100));
  print(
      "Reached goal in ${result.world.time} with ${result.actionLog.length} actions");
  for (var action in result.actionLog) {
    print(action);
  }
}
