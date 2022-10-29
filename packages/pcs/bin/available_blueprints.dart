import 'package:pcs/pcs.dart';
import 'package:pcs/structures.dart';

void main() {
  var unlocks = Unlocks(Progress(), 0);
  for (var item in unlocks.unlockedStructures) {
    print(item);
  }
}
