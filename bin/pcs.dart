import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main(List<String> arguments) {
  print("Simulating...");

  // Currently actions without regard for cost.
  // Next step is to plan ignoring inventory (and maybe energy)?
  // -- Creating necessary sub-plans for

  var stage = stageByName("Blue Sky");
  var goal = Goal(ti: stage.startsAt);
  var result = simulate(World.empty(), Sprinter(), goal);

  // for (var action in result.actionLog) {
  //   print(action);
  // }
  print(
      "Reached goal in ${result.world.time}s with ${result.actionLog.length} actions");
}
