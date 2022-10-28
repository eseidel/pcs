import 'package:pcs/structures.dart';

String toCSV(Item item) {
  String dependency(Item structure, int index) {
    if (index < structure.cost.length) {
      return structure.cost[index].key;
    } else {
      return '';
    }
  }

  String emptyZero(double value) {
    if (value == 0) {
      return '';
    } else {
      return value.toString();
    }
  }

  var buffer = StringBuffer();
  buffer.write('${item.key},');
  buffer.write('${item.name},');
  buffer.write('${item.type.name},');
  buffer.write('${emptyZero(item.energy)},');
  buffer.write('${emptyZero(item.progress.oxygen.ppq)},');
  buffer.write('${emptyZero(item.progress.biomass.grams)},');
  buffer.write('${emptyZero(item.progress.heat.pK)},');
  buffer.write('${emptyZero(item.progress.pressure.nPa)},');
  for (int i = 0; i < 8; i++) {
    buffer.write('${dependency(item, i)},');
  }
  buffer.write(dependency(item, 8));
  return buffer.toString();
}

void main() {
// key,name,type,power,oxygen,biomass,heat,pressure,dependency_1,dependency_2,dependency_3,dependency_4,dependency_5,dependency_6,dependency_7,dependency_8,dependency_9

  for (var item in Items.all) {
    print(toCSV(item));
  }
}
