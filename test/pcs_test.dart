import 'dart:math';

import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

import 'package:test/test.dart';

void main() {
  test('canBuild', () {
    var structure = strutureWithName("Wind Turbine");
    expect(canAfford(structure, 0, ItemCounts.fromItems([Item.iron])), isTrue);
  });

  test('applyAction', () {
    var afterGather =
        applyAction(Gather(resource: Item.iron, time: 1), World.empty());

    expect(afterGather.time, 1);
    expect(afterGather.inventory.countOf(Item.iron), 1);

    var turbine = strutureWithName("Wind Turbine");
    var afterBuild = applyAction(Build(turbine), afterGather);

    expect(afterBuild.time, 2);
    expect(afterBuild.structures.first, turbine);
    expect(afterBuild.availableEnergy, turbine.energy);
    expect(afterBuild.inventory.countOf(Item.iron), 0);
  });

  test('Plan.executionTime', () {
    var turbine = strutureWithName("Wind Turbine");
    var buildTurbine = Build(turbine);
    var plan = Plan([buildTurbine, buildTurbine]);
    expect(buildTurbine.time, greaterThan(0));
    expect(plan.executionTime, buildTurbine.time * 2);
  });

  test('unit types toString', () {
    expect(Ti(1).toString(), "1.0ti");
    expect(kTi(1).toString(), "1.0kTi");
    expect(Ti.kilo(1).toString(), "1.0kTi");
    expect(Ti.mega(1).toString(), "1.0MTi");
    expect(Ti.giga(1).toString(), "1.0GTi");
    expect(Ti.tera(1).toString(), "1.0TTi");

    expect(ppq(1).toString(), "1.0ppq");
    expect(ppt(1).toString(), "1.0ppt");
    expect(ppb(1).toString(), "1.0ppb");
    expect(ppm(1).toString(), "1.0ppm");

    expect(pK(1).toString(), "1.0pK");
    expect(nK(1).toString(), "1.0nK");
    expect(uK(1).toString(), "1.0uK");

    expect(nPa(1).toString(), "1.0nPa");
    expect(uPa(1).toString(), "1.0uPa");
    expect(mPa(1).toString(), "1.0mPa");

    expect(g(1).toString(), "1.0g");
  });
}
