import 'dart:io';
import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

String structureCountsString(World world) {
  // Count structures
  var structureCounts = <String, int>{};
  for (var structure in world.structures) {
    var name = structure.name;
    var count = structureCounts[name] ?? 0;
    structureCounts[name] = count + 1;
  }
  var entries = structureCounts.entries.toList();
  // Sort by count
  entries.sort((a, b) => -a.value.compareTo(b.value));

  var buffer = StringBuffer();
  buffer.writeln("Structures:");
  for (var entry in entries) {
    buffer.writeln("${entry.key} : ${entry.value}");
  }
  return buffer.toString();
}

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
      output.writeln(
          "${world.time.toStringAsFixed(0)}s : ${world.totalProgress}");
      lastLogTime = world.time;
    }
  }

  output.writeln(structureCountsString(world));
  output.writeln("${world.time.toStringAsFixed(0)}s : ${world.totalProgress}");
  output.writeln(
      "Reached ${stage.name} in ${world.time.toStringAsFixed(0)}s with ${actionLog.length} actions.");

  outputFile.writeAsStringSync(output.toString());
}