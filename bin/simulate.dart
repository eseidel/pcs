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

Iterable<Structure> unlockableStructuresBeforeGoal(Goal goal) sync* {
  for (var structure in allStructures) {
    var unlockAsTi = structure.unlocksAt.toTi();
    if (unlockAsTi.value != 0 && unlockAsTi < goal.toTi()) {
      yield structure;
    }
  }
}

Set<String> unlockedStructureNames(World world) {
  return Set.from(world.unlockedStructures.map((structure) => structure.name));
}

void main(List<String> arguments) {
  var stage = stageByName("Blue Sky");
  var stageGoal = Goal(ti: stage.startsAt);

  var outputPath = 'output_log.txt';
  var outputFile = File(outputPath);
  var output = StringBuffer();

  print("Simulating to ${stage.name} into $outputPath...");

  var world = World.empty();
  var actor = Sprinter();
  var actionLog = <Action>[];
  var unlockOrder = <Structure>[];
  var previousTime = world.time;
  var lastLogTime = world.time;
  var logFrequency = 60;

  // var possibleSubGoals = unlockableStructuresBeforeGoal(stageGoal)
  //     .map((structure) => structure.unlocksAt)
  //     .toList();

  // possibleSubGoals.sort((a, b) {
  //   return a.toTi().value.compareTo(b.toTi().value);
  // });

  // var goals = possibleSubGoals + [stageGoal];
  var lastUnlockedNames = unlockedStructureNames(world);

  var goals = [stageGoal];
  for (var goal in goals) {
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
      if (world.unlockedStructures.length > lastUnlockedNames.length) {
        var currentUnlockedNames = unlockedStructureNames(world);
        var unlockedNamesDelta =
            currentUnlockedNames.difference(lastUnlockedNames);
        for (var name in unlockedNamesDelta) {
          var structure = strutureWithName(name);
          output
              .writeln("Unlocked: ${structure.name} at ${structure.unlocksAt}");
          unlockOrder.add(structure);
        }
        lastUnlockedNames = currentUnlockedNames;
      }
    }

    output.writeln("Goal reached: $goal");
  }

  output.writeln("Unlock Order:");
  var number = 1;
  for (var structure in unlockOrder) {
    output.writeln("${number++}. ${structure.name} at ${structure.unlocksAt}");
  }

  output.writeln("Structure counts:");
  output.writeln(structureCountsString(world));

  output.writeln("${world.time.toStringAsFixed(0)}s : ${world.totalProgress}");
  output.writeln(
      "Reached ${stage.name} in ${world.time.toStringAsFixed(0)}s with ${actionLog.length} actions.");

  outputFile.writeAsStringSync(output.toString());
}
