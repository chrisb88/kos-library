// ------- To Mun
// Performs a launch to the mun.
// Parameter:
// - launchAltitude: in m above kerbin
// - targetAltitude: in m above the mun
@LAZYGLOBAL off.
runoncepath("0:/lib/status").

parameter launchAltitude is 100000,
        targetAltitude is 20000.

set target to Mun.
local targetName is target:name.
status("Starting to " + targetName + "!").
runpath("0:/launch", launchAltitude).
runpath("0:/circularize", launchAltitude).
runpath("0:/mun-transfer", targetAltitude).
runpath("0:/circularize", targetAltitude, "periapsis", 0.05).
status("We have arrived at " + targetName + "!").
