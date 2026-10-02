# Changelog

## 0.4.1 (2026-10-02)

### Fixed

- The event's `distanceDelta` is the distance the object has moved since the gesture began, as documented in 2015. It was the distance from the touch to the middle of the gesture, and `nil` for an object without a `scale` action.
- `deactivate()` on an object that was never activated does nothing; it raised an error.
- `activate()` with an unknown action raises an error that names it, at your call, before touching the object; it printed a warning and then failed inside the module.

### Added

- The README: Quick Start, API, Configuration, Known Issues, Development; an examples README with a screenshot.

## 0.4.0 (2026-10-01)

### Fixed

- Touches reach the object again: the module called the Touch Manager as `TouchMgr:register()`, `:unregister()`, `:setFocus()` and `:unsetFocus()`, which passed the Touch Manager itself as the object, so `activate()` did nothing with Touch Manager 2.x.
- Rotating works both ways and through any number of turns. A turn that left its starting quadrant clockwise (from fingers side by side, any clockwise turn) didn't rotate the object, and the angle could jump when crossing quadrants; the angle is now tracked from one move to the next.
- An object without a `scale` action no longer gets `nan` for its `x` and `y` when a touch starts on its centre (`0/0` while working out a scale it doesn't use). Without a `rotate` action, turning two fingers moves the object only with their midpoint; it swung around them.
- The debug markers (three coloured squares at the top left of every app) are off.
- The module no longer sets globals (`checkBounds`, `updateObject`, `multitouchTouchHandler`, `processParameters`, `touch`, `midpoint`, `xPos`, `yPos` and others).

### Added

- `MultiTouch.VERSION`.
- The Snakemake build: `Snakefile`, `dmc_corona/` with dmc-corona-boot 1.6.0 and dmc-touchmanager 2.1.0, `dmc_corona.cfg`; the module loads `dmc_corona_boot` if it's there.
- An example app, `examples/dmc-multitouch-basic`: drag a square, pinch and turn it.
- Unit tests (stand-in Touch Manager), and `tests/run_unit.sh` to run them with plain Lua 5.1.
