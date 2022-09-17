// ------- Circularize
// Circularizes the orbit at apoapsis to the given altitude.
// Parameter:
// - altitude: in m
@LAZYGLOBAL off.
runoncepath("0:/lib/status").
runoncepath("0:/lib/maneuver").

global function circularize {
    // todo choose where to burn (apoapsis, periapsis)
    parameter altitude.

    status("Circularizing to " + altitude + "m...").

    coastToSpace().
    local dV is doCalculateDeltaVForCircularOrbit(altitude).
    executeManeuver(list(time:seconds + eta:apoapsis, 0, 0, dV)).
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
    parameter altitude.
    // todo account for a different orbit than apoapsis, use given altitude
    debug("Caluclating deltaV for circular orbit:").

    local a is orbit:semiMajorAxis.
    local r is orbit:apoapsis + body:radius.

    local vCurrentApoapsis is calculateOrbitSpeed(r, a).
    debug("SpeedAtApoapsis: " + round(vCurrentApoapsis, 2)).

    local vOrbitCircular is calculateOrbitSpeed(r, r).
    debug("SpeedOrbit: " + round(vOrbitCircular, 2)).

    local vD is vOrbitCircular - vCurrentApoapsis.
    status("Need " + round(vD, 2) + " m/s deltaV for circularization").

    return vD.
}

function calculateOrbitSpeed {
    parameter r, a.

    // vis-viva equation
    // v^2 = Mu * (2/r - 1/a)

    return sqrt(body:mu * (2 / r - 1 / a)).
}
