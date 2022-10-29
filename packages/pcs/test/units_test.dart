import 'package:pcs/units.dart';

import 'package:test/test.dart';

void main() {
  test('unit types toString', () {
    expect(Ti(1).toString(), "1.0ti");
    expect(Ti.kilo(1).toString(), "1.0kTi");
    expect(Ti.mega(1).toString(), "1.0MTi");
    expect(Ti.giga(1).toString(), "1.0GTi");
    expect(Ti.tera(1).toString(), "1.0TTi");

    expect(O2.ppq(1).toString(), "1.0ppq");
    expect(O2.ppt(1).toString(), "1.0ppt");
    expect(O2.ppb(1).toString(), "1.0ppb");
    expect(O2.ppm(1).toString(), "1.0ppm");

    expect(Heat.pK(1).toString(), "1.0pK");
    expect(Heat.nK(1).toString(), "1.0nK");
    expect(Heat.uK(1).toString(), "1.0uK");

    expect(Pressure.nPa(1).toString(), "1.0nPa");
    expect(Pressure.uPa(1).toString(), "1.0uPa");
    expect(Pressure.mPa(1).toString(), "1.0mPa");

    expect(Mass.g(1).toString(), "1.0g");
    expect(Mass.g(1000).toString(), "1.0kg");
    expect(Mass.g(1000000).toString(), "1.0t");
    expect(Mass.g(1000000000).toString(), "1.0kt");
  });
}
