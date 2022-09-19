// ------- Circularize
// Circularizes the orbit at apoapsis to the given altitude.
// Parameter:
// - altitude: in m
// - apsis to start circularizing (apoapsis, periapsis)
// - allowed altitude deviation in percent
parameter altitude is 100000, useApsis is "apoapsis", maxAllowedAltitudeDeviation is 0.025.

runoncepath("0:/lib/circularize.ks").

circularize(altitude, useApsis, maxAllowedAltitudeDeviation).
