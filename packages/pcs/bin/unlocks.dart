import 'package:pcs/structures.dart';

void main() {
// Print unlockables in same order/format as wiki for easy comparison.
// https://planet-crafter.fandom.com/wiki/Blueprints
  var items = <String, List<Item>>{};
  for (var item in Items.all) {
    if (item.unlocksAt.isZero) {
      continue;
    }
    items[item.unlocksAt.type] ??= [];
    items[item.unlocksAt.type]!.add(item);
  }
  for (var type in items.keys) {
    items[type]!.sort(
        (a, b) => a.unlocksAt.toTi().value.compareTo(b.unlocksAt.toTi().value));
    print('== $type ==');
    var i = 1;
    for (var item in items[type]!) {
      print('$i. ${item.unlocksAt} ${item.name}');
      i++;
    }
  }
}
