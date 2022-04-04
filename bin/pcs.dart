import 'package:pcs/pcs.dart';

void main(List<String> arguments) {
  print("Simulating...");

  // Currently actions without regard for cost.
  // Next step is to plan ignoring inventory (and maybe energy)?
  // -- Creating necessary sub-plans for

  var result = simulate(World.empty(), Sprinter(), Goal(100));

  for (var action in result.actionLog) {
    print(action);
  }
  print(
      "Reached goal in ${result.world.time}s with ${result.actionLog.length} actions");
}
