// ------- Circularize

parameter altitude is 100000, useApsis is "apoapsis", maxAllowedAltitudeDeviation is 0.025.

runoncepath("0:/lib/circularize.ks").

circularize(altitude, useApsis, maxAllowedAltitudeDeviation).
