Planet Crafter Simulator/Solver

An attempt at simulating enough of Planet Crafter to guess at what an optimium route might look like.

# What's here

A script for simulating building towards Blue Sky:
```
dart run .\bin\simulate.dart
Simulating to Blue Sky into output_log.txt...
```

A script for examining costs (and expeted tiDelta/s payoffs) for
building structures based on gather/build time costs:
```
dart run .\bin\ti_structure_values.dart
Drill T4 time: 3388.0 tiDelta: 484.0ti tiDelta/time: 0.1429
Drill T3 time: 183.0 tiDelta: 19.5ti tiDelta/time: 0.1066
Vegetube T3 time: 123.0 tiDelta: 13.0ti tiDelta/time: 0.1057
Drill T2 time: 37.0 tiDelta: 1.6ti tiDelta/time: 0.0432
Vegetube T2 time: 47.0 tiDelta: 1.2ti tiDelta/time: 0.0255
Heater T2 time: 217.0 tiDelta: 4.5ti tiDelta/time: 0.0207
Drill T1 time: 32.0 tiDelta: 0.2ti tiDelta/time: 0.0063
Heater T1 time: 92.0 tiDelta: 0.3ti tiDelta/time: 0.0033
Vegetube T1 time: 397.0 tiDelta: 0.1ti tiDelta/time: 0.0004
```

A script for examining energy/s payoff vs. build time:
```
dart run .\bin\energy_structure_values.dart
Solar Panel T1 time: 21.0 energy: 6.5 ratio: 0.31
Solar Panel T2 time: 86.0 energy: 19.5 ratio: 0.23
Wind Turbine time: 6.0 energy: 1.2 ratio: 0.20
Nuclear Fusion Generator time: Infinity energy: 1835.0 ratio: 0.00
Nuclear Reactor T1 time: Infinity energy: 86.5 ratio: 0.00
Nuclear Reactor T2 time: Infinity energy: 331.5 ratio: 0.00
```


TODO
* Add more structures
* Merge Gathers together
* Simulate inventory
* Simulate non-respawning resources (increasing gather base costs?)
* Gathers should have a base-cost and then smaller per-item cost?
* Simulate oxygen, food, or water?