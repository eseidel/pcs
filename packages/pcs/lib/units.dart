class Progress {
  final Pressure pressure;
  final O2 oxygen;
  final Heat heat;
  final Biomass biomass;

  // Used by tests which need a progress where everything is unlocked.
  const Progress.allUnlocks()
      : pressure = const Pressure.max(),
        oxygen = const O2.max(),
        heat = const Heat.max(),
        biomass = const Biomass.max();

  const Progress(
      {this.pressure = const Pressure.zero(),
      this.oxygen = const O2.zero(),
      this.heat = const Heat.zero(),
      this.biomass = const Biomass.zero()});

  Ti get ti => pressure.toTi() + oxygen.toTi() + heat.toTi() + biomass.toTi();

  bool get isZero =>
      pressure.isZero && oxygen.isZero && heat.isZero && biomass.isZero;

  Progress operator +(Progress other) {
    return Progress(
      pressure: pressure + other.pressure,
      oxygen: oxygen + other.oxygen,
      heat: heat + other.heat,
      biomass: biomass + other.biomass,
    );
  }

  Progress operator -(Progress other) {
    return Progress(
      pressure: pressure - other.pressure,
      oxygen: oxygen - other.oxygen,
      heat: heat - other.heat,
      biomass: biomass - other.biomass,
    );
  }

  Progress scaleBy(double timeDelta) {
    return Progress(
      pressure: pressure.scaleBy(timeDelta),
      oxygen: oxygen.scaleBy(timeDelta),
      heat: heat.scaleBy(timeDelta),
      biomass: biomass.scaleBy(timeDelta),
    );
  }

  Progress operator *(Progress other) {
    return Progress(
      pressure: pressure * other.pressure,
      oxygen: oxygen * other.oxygen,
      heat: heat * other.heat,
      biomass: biomass * other.biomass,
    );
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write("$ti");
    buffer.write(" o2: $oxygen");
    buffer.write(" heat: $heat");
    buffer.write(" pressure: $pressure");
    buffer.write(" biomass: $biomass");
    return buffer.toString();
  }
}

class Ti {
  final double value;
  const Ti(this.value);
  const Ti.zero() : value = 0;
  bool isZero() => value == 0;

  static const double kiloMultiplier = 1000;
  static const double megaMultiplier = 1000000;
  static const double gigaMultiplier = 1000000000;
  static const double teraMultiplier = 1000000000000;
  static const double petaMultiplier = 1000000000000000;

  const Ti.kilo(double kiloTi) : value = kiloTi * kiloMultiplier;
  const Ti.mega(double megaTi) : value = megaTi * megaMultiplier;
  const Ti.giga(double gigaTi) : value = gigaTi * gigaMultiplier;
  const Ti.tera(double teraTi) : value = teraTi * teraMultiplier;
  const Ti.peta(double petaTi) : value = petaTi * petaMultiplier;

  Ti operator +(Ti other) => Ti(value + other.value);
  Ti operator -(Ti other) => Ti(value - other.value);
  Ti scaleBy(double multiplier) => Ti(value * multiplier);
  Ti operator *(Ti other) => Ti(value * other.value);
  bool operator <(Ti other) => value < other.value;
  bool operator >=(Ti other) => value >= other.value;

  @override
  String toString() {
    var value = this.value;
    var suffix = "ti";
    if (value >= teraMultiplier) {
      value /= teraMultiplier;
      suffix = 'TTi';
    } else if (value >= gigaMultiplier) {
      value /= gigaMultiplier;
      suffix = 'GTi';
    } else if (value >= megaMultiplier) {
      value /= megaMultiplier;
      suffix = 'MTi';
    } else if (value >= kiloMultiplier) {
      value /= kiloMultiplier;
      suffix = 'kTi';
    }
    return "${value.toStringAsFixed(1)}$suffix";
  }
}

class O2 {
  final double ppq; // Parts per quadrillion? e-15?
  const O2.ppq(this.ppq); // e-15
  const O2.ppt(double ppt) : ppq = ppt * 1000; // e-12
  const O2.ppb(double ppb) : ppq = ppb * 1000000; // e-9
  const O2.ppm(double ppm) : ppq = ppm * 1000000000; // e-6

  const O2.zero() : ppq = 0;
  bool get isZero => ppq == 0;
  const O2.max() : ppq = double.maxFinite;

  O2 operator +(O2 other) => O2.ppq(ppq + other.ppq);
  O2 operator -(O2 other) => O2.ppq(ppq - other.ppq);
  O2 scaleBy(double multiplier) => O2.ppq(ppq * multiplier);
  O2 operator *(O2 other) => O2.ppq(ppq * other.ppq);
  bool operator >=(O2 other) => ppq >= other.ppq;
  Ti toTi() => Ti(ppq);

  static const double pptMultiplier = 1000;
  static const double ppbMultiplier = 1000000;
  static const double ppmMultiplier = 1000000000;

  @override
  String toString() {
    var value = ppq;
    var suffix = "ppq";
    if (value >= ppmMultiplier) {
      value /= ppmMultiplier;
      suffix = 'ppm';
    } else if (value >= ppbMultiplier) {
      value /= ppbMultiplier;
      suffix = 'ppb';
    } else if (value >= pptMultiplier) {
      value /= pptMultiplier;
      suffix = 'ppt';
    }
    return "${value.toStringAsFixed(1)}$suffix";
  }
}

class Heat {
  final double pK; // picokelvin, e-12.
  const Heat.pK(this.pK);
  const Heat.nK(double nK) : pK = nK * 1000; // e-9
  const Heat.uK(double uK) : pK = uK * 1000000; // e-6

  const Heat.zero() : pK = 0;
  bool get isZero => pK == 0;
  const Heat.max() : pK = double.maxFinite;

  Heat operator +(Heat other) => Heat.pK(pK + other.pK);
  Heat operator -(Heat other) => Heat.pK(pK - other.pK);
  Heat scaleBy(double multiplier) => Heat.pK(pK * multiplier);
  Heat operator *(Heat other) => Heat.pK(pK * other.pK);
  bool operator >=(Heat other) => pK >= other.pK;
  Ti toTi() => Ti(pK);

  static const double nanoMultiplier = 1000;
  static const double microMultiplier = 1000000;

  @override
  String toString() {
    var value = pK;
    var suffix = "pK";
    if (value >= microMultiplier) {
      value /= microMultiplier;
      suffix = 'uK';
    } else if (value >= nanoMultiplier) {
      value /= nanoMultiplier;
      suffix = 'nK';
    }
    return "${value.toStringAsFixed(1)}$suffix";
  }
}

class Pressure {
  final double nPa; // nanopascals e-9
  const Pressure.nPa(this.nPa);
  const Pressure.uPa(double uPa) : nPa = uPa * 1000;
  const Pressure.mPa(double mPa) : nPa = mPa * 1000000;

  const Pressure.zero() : nPa = 0;
  bool get isZero => nPa == 0;

  const Pressure.max() : nPa = double.maxFinite;
  Pressure operator +(Pressure other) => Pressure.nPa(nPa + other.nPa);
  Pressure operator -(Pressure other) => Pressure.nPa(nPa - other.nPa);
  Pressure scaleBy(double multiplier) => Pressure.nPa(nPa * multiplier);
  Pressure operator *(Pressure other) => Pressure.nPa(nPa * other.nPa);
  bool operator >=(Pressure other) => nPa >= other.nPa;
  Ti toTi() => Ti(nPa);

  static const double microMultiplier = 1000;
  static const double milliMultiplier = 1000000;

  @override
  String toString() {
    var value = nPa;
    var suffix = "nPa";
    if (value >= milliMultiplier) {
      value /= milliMultiplier;
      suffix = 'mPa';
    } else if (value >= microMultiplier) {
      value /= microMultiplier;
      suffix = 'uPa';
    }
    return "${value.toStringAsFixed(1)}$suffix";
  }
}

class Biomass {
  final double grams;
  const Biomass.g(this.grams); // grams
  const Biomass.zero() : grams = 0;
  bool get isZero => grams == 0;

  const Biomass.max() : grams = double.maxFinite;
  Biomass operator +(Biomass other) => Biomass.g(grams + other.grams);
  Biomass operator -(Biomass other) => Biomass.g(grams - other.grams);
  Biomass scaleBy(double multiplier) => Biomass.g(grams * multiplier);
  Biomass operator *(Biomass other) => Biomass.g(grams * other.grams);
  bool operator >=(Biomass other) => grams >= other.grams;
  Ti toTi() => Ti(grams);

  @override
  String toString() {
    // FIXME: Automatically scale printed units.
    return "${grams.toStringAsFixed(1)}g";
  }
}
