// ------- To Mun
// Performs a launch to the mun.
// Parameter:
// - launchAltitude: in m above kerbin
// - targetAltitude: in m above the mun
@LAZYGLOBAL off.
runoncepath("0:/lib/status").

parameter launchAltitude is 100000,
        targetAltitude is 20000,
        targetBody is Mun.

set target to targetBody. // sets map to target
local targetName is target:name.
status("Starting to " + targetBody:name + "!").
runpath("0:/launch", launchAltitude).
runpath("0:/circularize", launchAltitude).
runpath("0:/mun-transfer", targetAltitude, targetBody).
runpath("0:/circularize", targetAltitude, "periapsis", 0.05).
status("We have arrived at " + targetBody:name + "!").
