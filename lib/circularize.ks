// ------- Circularize
// Circularizes the orbit at apoapsis to the given altitude.
// Parameter:
// - altitude: in m
// - apsis to start circularizing (apoapsis, periapsis)
// - allowed altitude deviation in percent [0...1]
@LAZYGLOBAL off.
runoncepath("0:/lib/status").
runoncepath("0:/lib/maneuver").
runoncepath("0:/lib/math").
runoncepath("0:/lib/orbitmath").

global function circularize {
    parameter altitude, currentApsis, maxAllowedAltitudeDeviation.

    if currentApsis <> "apoapsis" and currentApsis <> "periapsis" {
        warning("Invalid parameter: " + currentApsis).
        set currentApsis to "apoapsis".
    }

    local bounds is getBounds(altitude, maxAllowedAltitudeDeviation).

    status("Circularizing to " + altitude + "m... [" + bounds[0] + "..." + bounds[1] + "]").

    coastToSpace().

    until isCircularizationComplete(altitude, maxAllowedAltitudeDeviation) {
        debug("Current apsis: " + currentApsis).

        local apsis is false.
        local currentEta is false.
        if currentApsis = "apoapsis" {
            set apsis to orbit:apoapsis.
            set currentEta to eta:apoapsis.
        } else {
            set apsis to orbit:periapsis.
            set currentEta to eta:periapsis.
        }

        local dV is doCalculateDeltaVForCircularOrbit(altitude, apsis).
        executeManeuver(list(time:seconds + currentEta, 0, 0, dV)).
        wait 5.

        set currentApsis to getNextApsis().
    }
}

local function getNextApsis {
    local etaApoapsis is eta:apoapsis.
    local etaPeriapsis is eta:periapsis.

    if etaApoapsis < etaPeriapsis {
        return "apoapsis".
    }

    return "periapsis".
}

local function isCircularizationComplete {
    parameter altitude, deviation.

    debug("Orbit eccentricity: " + orbit:eccentricity).
    return isWithinBounds(orbit:apoapsis, altitude, deviation) and isWithinBounds(orbit:periapsis, altitude, deviation).
}

local function coastToSpace {
    if body:atm:exists {
        local endOfAtmosphere is body:atm:height.
        debug("Atmosphere until " + endOfAtmosphere + "m").
        if ship:altitude < endOfAtmosphere {
            status("Coasting to space at " + endOfAtmosphere + "m").
            set warp to 3.
            wait until ship:altitude > endOfAtmosphere.
            set warp to 1.

            return.
        }

        debug("Already in space").

        return.
    }

    debug("No atmosphere").
}

function doCalculateDeltaVForCircularOrbit {
    parameter altitude, startApsis.

    debug("Caluclating deltaV for new orbit:").

    local a is orbit:semiMajorAxis.
    local r is startApsis + body:radius. // distance from center of body of which speed is to be calculated

    debug("start a: " + round(a)).
    debug("start r: " + round(r)).

    local vCurrentApsis is calculateOrbitSpeed(r, a).
    debug("Speed at next apsis: " + round(vCurrentApsis, 2)).

    set a to (startApsis + altitude) / 2 + body:radius.

    debug("target a = (" + round(startApsis) + " + " + round(altitude) + ") / 2 + " + body:radius).
    debug("target a: " + round(a)).
    debug("target r: " + round(r)).

    local vTargetApsis is calculateOrbitSpeed(r, a).
    debug("Speed at target apsis: " + round(vTargetApsis, 2)).

    local vD is vTargetApsis - vCurrentApsis.
    status("Need " + round(vD, 2) + " m/s deltaV to change orbit").

    return vD.
}
