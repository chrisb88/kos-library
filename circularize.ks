// ------- Circularize
// Circularizes the orbit at apoapsis to the given altitude.
// Parameter:
// - altitude: in m
// - apsis to start circularizing (apoapsis, periapsis)
// - allowed altitude deviation in percent [0...1]
@LAZYGLOBAL off.
runoncepath("0:/lib/circularize.ks").

parameter altitude is 100000,
        useApsis is "apoapsis",
        maxAllowedAltitudeDeviation is 0.025.

circularize(altitude, useApsis, maxAllowedAltitudeDeviation).
