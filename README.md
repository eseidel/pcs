Planet Crafter Simulator/Solver

An attempt at simulating enough of Planet Crafter to guess at what an optimium route might look like.

Based on Early Access 0.4.007.
https://store.steampowered.com/app/1284190/The_Planet_Crafter/

# What's here

A script for simulating building towards the "Blue Sky" milestone:
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

# Current speedrun to Blue Sky guess?
* Heater T1 if you have iridium, Drill T1 otherwise.
* Skip VegeTube T1.  VegeTube T2 ASAP once unlocks and have plants.
* Drill T2 once unlocks.
* Upgrade all Heater T1s to T2s once unlocks.
* Drill T3 once unlocks (heat).
* Upgrade all VegeTube T2 to T3 once unlocks and have plants.
* Heater T3s once unlocks (not worth tearing down T2s?)

# Structure analysis
* Drill T1 tiDelta: 0.2ti unlocksAt: 0.0ti
  Meat an potatoes, build anytime.
* Heater T1 tiDelta: 0.3ti unlocksAt: 0.0ti
  Prefer when iridum is available.
* Vegetube T1 tiDelta: 0.1ti unlocksAt: 0.0ti
  Probably never build?
* Vegetube T2 tiDelta: 1.2ti unlocksAt: 500.0pK (500.0ti)
  Build whenever plants are avialable?
* Drill T2 tiDelta: 1.6ti unlocksAt: 1.2uPa (1.2kTi)
  Build as soon as available?  First unlock?
* Heater T2 tiDelta: 4.5ti unlocksAt: 1.9ppt (1.9kTi)
  Build whenever iridium + aluminum are avaialble?
* Vegetube T3 tiDelta: 13.0ti unlocksAt: 30.0ppt (30.0kTi)
  Replaces T2s once available.
* Drill T3 tiDelta: 19.5ti unlocksAt: 21.0nK (21.0kTi)
* Heater T3 tiDelta: 29.1ti unlocksAt: 80.0ppt (80.0kTi)
* Drill T4 tiDelta: 484.0ti unlocksAt: 41.0uK (41.0MTi)
* Grass Spreader tiDelta: 108.2ti unlocksAt: 150.0ppt (150.0kTi)
* Algae Generator T1 tiDelta: 127.6ti unlocksAt: 2.0uK (2.0MTi)
* Tree Spreader T2 tiDelta: 2.1kTi unlocksAt: 7.5ppm (7.5GTi)
* Flower Spreader tiDelta: 7.2ti unlocksAt: 2.5mPa (2.5MTi)

# TODO
* Add more structures
* Merge Gathers together
* Simulate inventory
* Simulate non-respawning resources (increasing gather base costs?)
* Gathers should have a base-cost and then smaller per-item cost?
* Support structure destruction.
* Support item construction/transmutation (e.g. iridium rod)
* Simulate oxygen, food, or water?
* Simulate "growing" in plant generators.
* Require construction/destruction chips.
* Require indoor space for indoor structures.


Planning should be done based on expected costs, rather than actual costs.
Execution should be done with actual costs.
e.g. Planning should use "average cost of 1 aluminium" instead of planning
a gather for aluminium and guessing that.
Similarly energy planning should be done based on "costs per unit energy"
rather than including avaiable energy (which biases towards building things
which cost less than avaiable energy but may be less efficient overall).