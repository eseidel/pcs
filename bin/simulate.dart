import 'dart:io';
import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main(List<String> arguments) {
  var stage = stageByName("Blue Sky");
  var goal = Goal(ti: stage.startsAt);

  var outputPath = 'output_log.txt';
  var outputFile = File(outputPath);
  var output = StringBuffer();

  print("Simulating to ${stage.name} into $outputPath...");

  var world = World.empty();
  var actor = Sprinter();
  var actionLog = <Action>[];
  var previousTime = world.time;
  var lastLogTime = world.time;
  var logFrequency = 60;

  while (!goal.wasReached(world.totalProgress)) {
    var result = planOneAction(world, actor, goal);
    world = result.world;
    actionLog.add(result.action);
    output.writeln(
        "${result.action} energy: ${world.availableEnergy.toStringAsFixed(1)}");

    assert(previousTime < world.time);

    if (world.time > lastLogTime + logFrequency) {
      output.writeln("${world.time}s : ${world.totalProgress}");
      lastLogTime = world.time;
    }
  }

  output.writeln(
      "Reached ${stage.name} in ${world.time}s with ${actionLog.length} actions.");

  outputFile.writeAsStringSync(output.toString());
}
