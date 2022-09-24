// ------- To Mun
// Performs a launch to the mun.
// Parameter:
// - launchAltitude: in m above kerbin
// - targetAltitude: in m above the mun
@LAZYGLOBAL off.
runoncepath("0:/lib/status").

parameter launchAltitude is 100000,
        targetAltitude is 20000.

status("Starting to the mun!").
runpath("0:/launch", launchAltitude).
runpath("0:/circularize", launchAltitude).
runpath("0:/mun-transfer", targetAltitude).
runpath("0:/circularize", targetAltitude, "periapsis").
status("We have arrived at the mun!").
