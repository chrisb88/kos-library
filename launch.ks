// ------- Launch
// Parameter:
// - launchAltitude: in m above kerbin
@LAZYGLOBAL off.
runoncepath("0:/lib/launch.ks").

parameter launchAltitude is 100000,
    launchDirection is 90.

launch(launchAltitude, launchDirection).
